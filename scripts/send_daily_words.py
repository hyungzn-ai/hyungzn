#!/usr/bin/env python3
"""
매일 카카오톡 '나에게 보내기'로 오늘의 영단어를 발송한다.

필요한 GitHub Secrets:
  KAKAO_REST_API_KEY  : 카카오 개발자 앱의 REST API 키
  KAKAO_REFRESH_TOKEN : talk_message 동의를 마친 리프레시 토큰

동작:
  1. state.json 의 cursor 부터 WORDS_PER_DAY 개를 꺼낸다
  2. 뜻이 없으면 무료 사전/번역으로 채우고 meanings 캐시에 적립한다
  3. 카카오톡으로 보내고 cursor 를 전진시킨 뒤 커밋한다
"""
import json
import os
import pathlib
import sys
import time
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
WORDS_PATH = ROOT / 'assets' / 'data' / 'words.json'
MEANINGS_PATH = ROOT / 'assets' / 'data' / 'word_meanings.json'
STATE_PATH = ROOT / 'data' / 'daily_state.json'

WORDS_PER_DAY = int(os.environ.get('WORDS_PER_DAY', '10'))
REST_KEY = os.environ.get('KAKAO_REST_API_KEY', '')
REFRESH_TOKEN = os.environ.get('KAKAO_REFRESH_TOKEN', '')


def http_post(url, data, headers=None):
    body = urllib.parse.urlencode(data).encode()
    req = urllib.request.Request(url, data=body, headers=headers or {})
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.loads(r.read().decode())


def http_get_json(url, timeout=15):
    req = urllib.request.Request(url, headers={'User-Agent': 'writemon-daily-words'})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read().decode())


def load_json(path, default):
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except Exception:
        return default


def save_json(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(obj, ensure_ascii=False, indent=0, separators=(',', ':')),
        encoding='utf-8',
    )


# ── 뜻 채우기 ──────────────────────────────────────────────────

def fetch_english_def(word):
    """dictionaryapi.dev (무료, 키 불필요) 에서 품사와 영어 정의를 가져온다."""
    try:
        data = http_get_json(
            'https://api.dictionaryapi.dev/api/v2/entries/en/' + urllib.parse.quote(word)
        )
        meaning = data[0]['meanings'][0]
        definition = meaning['definitions'][0]
        return {
            'pos': meaning.get('partOfSpeech', ''),
            'def': definition.get('definition', ''),
            'ex': definition.get('example', ''),
        }
    except Exception:
        return {'pos': '', 'def': '', 'ex': ''}


def fetch_korean(word):
    """MyMemory (무료) 로 한국어 뜻을 추정한다. 정확도는 보조 수준."""
    try:
        url = ('https://api.mymemory.translated.net/get?q='
               + urllib.parse.quote(word) + '&langpair=en|ko')
        data = http_get_json(url)
        text = (data.get('responseData') or {}).get('translatedText', '') or ''
        text = text.strip().strip(',').strip()
        if not text or text.lower() == word.lower():
            return ''
        return text[:40]
    except Exception:
        return ''


def enrich(word, meanings):
    """캐시에 없으면 채워 넣고, 채운 항목을 반환한다."""
    entry = meanings.get(word)
    if entry and entry.get('ko'):
        return entry, False

    eng = fetch_english_def(word)
    time.sleep(0.4)
    ko = fetch_korean(word)
    time.sleep(0.4)

    entry = {
        'ko': ko or '(뜻 미등록)',
        'pos': eng['pos'],
        'def': eng['def'][:160],
        'ex': eng['ex'][:120],
        'auto': True,   # 자동 생성 표시 — 직접 작성한 항목은 auto 가 없다
    }
    meanings[word] = entry
    return entry, True


# ── 카카오 ─────────────────────────────────────────────────────

def get_access_token():
    res = http_post(
        'https://kauth.kakao.com/oauth/token',
        {
            'grant_type': 'refresh_token',
            'client_id': REST_KEY,
            'refresh_token': REFRESH_TOKEN,
        },
        {'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'},
    )
    return res.get('access_token'), res.get('refresh_token')


def send_to_me(access_token, text, link_url):
    template = {
        'object_type': 'text',
        'text': text[:1000],
        'link': {'web_url': link_url, 'mobile_web_url': link_url},
        'button_title': '앱에서 복습하기',
    }
    return http_post(
        'https://kapi.kakao.com/v2/api/talk/memo/default/send',
        {'template_object': json.dumps(template, ensure_ascii=False)},
        {
            'Authorization': 'Bearer ' + access_token,
            'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
        },
    )


# ── 메인 ───────────────────────────────────────────────────────

def main():
    if not REST_KEY or not REFRESH_TOKEN:
        print('KAKAO_REST_API_KEY / KAKAO_REFRESH_TOKEN 시크릿이 없습니다.')
        return 1

    words = load_json(WORDS_PATH, {}).get('words', [])
    if not words:
        print('words.json 을 읽지 못했습니다.')
        return 1

    meanings = load_json(MEANINGS_PATH, {})
    state = load_json(STATE_PATH, {'cursor': 0, 'sentCount': 0})
    cursor = int(state.get('cursor', 0))

    if cursor >= len(words):
        cursor = 0  # 한 바퀴 다 돌면 처음부터 복습

    todays = words[cursor:cursor + WORDS_PER_DAY]

    lines = ['📚 오늘의 영단어 ' + str(len(todays)) + '개',
             '(' + str(cursor + 1) + '~' + str(cursor + len(todays)) +
             ' / ' + str(len(words)) + ')', '']
    changed = False
    for i, w in enumerate(todays, 1):
        entry, was_new = enrich(w, meanings)
        changed = changed or was_new
        pos = (' (' + entry['pos'] + ')') if entry.get('pos') else ''
        lines.append(str(i) + '. ' + w + pos)
        lines.append('   → ' + entry.get('ko', ''))
        if entry.get('ex'):
            lines.append('   💬 ' + entry['ex'])
    lines.append('')
    lines.append('내일 또 만나요! 🔥')

    text = '\n'.join(lines)

    access_token, new_refresh = get_access_token()
    if not access_token:
        print('액세스 토큰 발급 실패')
        return 1

    result = send_to_me(access_token, text, 'https://github.com/hyungzn-ai/hyungzn')
    print('kakao result:', result)

    state['cursor'] = cursor + len(todays)
    state['sentCount'] = int(state.get('sentCount', 0)) + len(todays)
    state['lastSent'] = time.strftime('%Y-%m-%d %H:%M:%S')
    save_json(STATE_PATH, state)
    if changed:
        save_json(MEANINGS_PATH, meanings)

    if new_refresh:
        print('::warning::리프레시 토큰이 갱신되었습니다. Secrets 를 업데이트하세요.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
