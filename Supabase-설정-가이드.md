# Supabase 설정 가이드 (4단계) — 태블릿 기준

준비물: 이메일 또는 GitHub 계정, 이번에 받은 파일 3개
(`index.html`, `schema.sql`, `seed.sql`)

> Supabase 화면은 자주 바뀝니다. 메뉴 이름이 조금 달라도 같은 기능을 찾으시면 됩니다.

---

## 1. 프로젝트 만들기

1. https://supabase.com 접속 → **Start your project** → GitHub 계정으로 로그인
2. **New project** 선택 (조직이 없으면 먼저 Organization 생성, 이름 아무거나)
3. 입력
   - Name: `munhak-lab`
   - Database Password: **Generate a password**로 만들고 **반드시 메모**해 두세요 (나중에 DB 직접 접속 때 필요)
   - Region: **Northeast Asia (Seoul)**
   - Plan: **Free**
4. **Create new project** → 1~2분 기다리면 대시보드가 열립니다.

> 참고: 무료 프로젝트는 일정 기간(보통 1주일) 아무 접속이 없으면 일시 정지될 수 있습니다. 정지되면 대시보드에서 Restore 하면 됩니다.

## 2. 테이블과 보안 정책 만들기 (schema.sql)

1. 왼쪽 메뉴 **SQL Editor** → **New query**
2. `schema.sql` 파일을 열어 **내용 전체를 복사**해서 붙여넣기
3. **Run** (또는 Ctrl+Enter)
4. 결과가 **Success. No rows returned** 이면 성공
   - 빨간 오류가 나오면 오류 문구를 그대로 저에게 알려 주세요.

## 3. 샘플 데이터 넣기 (seed.sql)

1. SQL Editor에서 다시 **New query**
2. `seed.sql` 내용 전체를 붙여넣고 **Run**
3. 확인: 왼쪽 **Table Editor** → `works` 테이블에 작품 12개, `analyses`에 18행이 보이면 성공

## 4. 접속 정보 복사하기

1. 왼쪽 아래 **Project Settings**(톱니바퀴) → **API** (또는 **API Keys**)
2. 두 가지를 복사해서 메모장에 둡니다.
   - **Project URL** — `https://xxxxxxxx.supabase.co`
   - **anon (public) 키** 또는 **publishable 키** — 긴 문자열
3. ⚠️ **`service_role` 키나 `secret` 키는 절대 사용하지 마세요.** 이 키는 모든 보안 정책을 무시합니다. (실수로 넣으면 사이트가 막도록 해 두었습니다.)

> anon/publishable 키는 웹사이트에 그대로 들어가도 안전하도록 만들어진 키입니다. 데이터 보호는 2번에서 만든 보안 정책(RLS)이 담당합니다.

## 5. index.html에 넣기

1. `index.html`을 열고 위쪽의 아래 부분을 찾습니다.

```html
window.MUNHAK_CONFIG = {
  SUPABASE_URL: "YOUR_SUPABASE_URL",
  SUPABASE_ANON_KEY: "YOUR_SUPABASE_ANON_KEY"
};
```

2. 따옴표 안의 값만 4번에서 복사한 값으로 바꿉니다. (따옴표는 지우지 마세요)
3. GitHub에서 기존 `index.html`을 이 파일로 덮어쓰기 → 커밋 → Cloudflare 자동 배포 (1~2분)

## 6. 연결 확인

사이트 맨 아래 문구를 확인합니다.

| 표시 | 의미 |
|---|---|
| `데이터: 샘플 모드` | 설정 값이 아직 YOUR_… 그대로 |
| `데이터: Supabase 연결됨` | 정상 연결 |
| `데이터: 설정 오류` | 화면에 오류 이유가 나옵니다 |

정상이라면 작품 목록이 DB에서 불러온 12개로 보이고, 「진달래꽃」은 14개 항목 전체, 「성산별곡」은 4개 항목 미리보기만 보입니다. 잠긴 항목은 서버가 아예 내려 주지 않습니다.

---

## PDF 기능

**A. PDF로 저장 (바로 사용 가능)**
작품 상세 화면의 **「PDF로 저장 (인쇄)」** 버튼 → 인쇄 창에서 대상을 **PDF로 저장**으로 선택합니다. 지금 화면에 보이는(열람 권한이 있는) 항목만 PDF에 담기고, 헤더·목차·버튼은 빠집니다.

**B. 미리 만든 PDF 파일 다운로드 (선택, 6단계에서 관리자 화면으로 편해집니다)**
지금 시험해 보려면:
1. **Table Editor → works**에서 작품 한 줄의 `id`(긴 문자열)를 복사
2. **Storage → work-files** 버킷에서 폴더를 만들고 **이름을 그 id로** 지정한 뒤 PDF 업로드
   (파일 경로가 `작품id/파일명.pdf` 형태여야 합니다)
3. **Table Editor → work_files**에서 행 추가
   - `work_id`: 위의 작품 id
   - `storage_path`: `작품id/파일명.pdf`
   - `file_name`: 화면에 보일 이름 (예: `진달래꽃-분석.pdf`)
4. 사이트에서 해당 작품을 열면 **「PDF 다운로드」** 버튼이 나옵니다.

무료 작품의 PDF는 누구나, 프리미엄 작품의 PDF는 구매자(와 관리자)만 받을 수 있고, 링크는 60초만 유효합니다.

---

## 관리자 지정 (5단계 회원가입 구현 후)

5단계에서 회원가입을 만든 뒤, 본인 계정으로 가입하고 SQL Editor에서 한 번만 실행합니다.

```sql
update public.profiles set role = 'admin' where email = '본인이메일@example.com';
```

일반 사용자는 브라우저에서 이 값을 바꿀 수 없도록 막아 두었습니다.
