# 문학연구소

수능 문학(고전·현대) 분석 플랫폼. 현재 **1단계: 설계 + 메인 페이지**.

## 로컬에서 확인
`index.html` 파일을 브라우저로 열면 바로 확인됩니다. (빌드 불필요)

## GitHub → Cloudflare Pages 배포
1. GitHub에서 새 저장소(Repository)를 만들고 이 폴더의 파일을 모두 올립니다. (태블릿은 GitHub 웹의 `Add file → Upload files` 사용)
2. Cloudflare 대시보드 → `Workers & Pages` → `Create` → `Pages` → `Connect to Git`
3. 방금 만든 저장소를 선택
4. 빌드 설정: Framework preset `None`, Build command 비워둠, Build output directory `/` (비워도 됨)
5. `Save and Deploy` → `https://프로젝트명.pages.dev` 주소가 생성됩니다.
6. 이후 GitHub에서 파일을 수정·커밋하면 자동으로 다시 배포됩니다.
