/*
 * 1단계 확인용 샘플 데이터
 * ------------------------------------------------------------
 * - 실제 분석 자료가 아니라, 화면이 제대로 나오는지 확인하기 위한 목록입니다.
 * - 4단계(Supabase 연결)에서 이 파일은 삭제되고, 데이터베이스(works 테이블)에서 불러옵니다.
 * - price(가격), popularity(인기 순위용 점수)는 임의의 샘플 값입니다.
 *
 * category : "classic"(고전문학) | "modern"(현대문학)
 * access   : "free"(무료) | "premium"(프리미엄)
 * exam     : true이면 '수능·모의평가 기출 분석' 구역에 표시 (샘플 지정)
 */
window.SAMPLE_WORKS = [
  { id: "w01", title: "성산별곡", author: "정철", era: "조선 전기", genre: "가사", category: "classic",
    access: "premium", price: 3000, exam: true, popularity: 98, createdAt: "2026-11-10",
    summary: "성산의 자연 속 삶과 임금에 대한 그리움을 함께 노래한 가사 작품." },
  { id: "w02", title: "탄궁가", author: "박인로", era: "조선 후기", genre: "가사", category: "classic",
    access: "premium", price: 3000, exam: true, popularity: 95, createdAt: "2026-11-09",
    summary: "궁핍한 생활 속에서도 안분지족의 자세를 드러내는 가사 작품." },
  { id: "w03", title: "관동별곡", author: "정철", era: "조선 전기", genre: "가사", category: "classic",
    access: "free", price: 0, exam: false, popularity: 90, createdAt: "2026-11-05",
    summary: "관동 지방의 명승을 유람하며 느낀 감흥과 선정(善政)의 포부를 담은 기행 가사." },
  { id: "w04", title: "사미인곡", author: "정철", era: "조선 전기", genre: "가사", category: "classic",
    access: "premium", price: 3000, exam: true, popularity: 88, createdAt: "2026-11-02",
    summary: "임금을 향한 그리움을 임을 그리는 여인의 목소리로 표현한 작품." },
  { id: "w05", title: "누항사", author: "박인로", era: "조선 후기", genre: "가사", category: "classic",
    access: "premium", price: 3000, exam: false, popularity: 80, createdAt: "2026-10-28",
    summary: "가난한 선비의 현실 고민과 안빈낙도의 다짐을 그린 가사." },
  { id: "w06", title: "규원가", author: "허난설헌(전승)", era: "조선 중기", genre: "가사", category: "classic",
    access: "free", price: 0, exam: false, popularity: 72, createdAt: "2026-10-20",
    summary: "규방 여인의 외로움과 원망을 노래한 규방 가사." },

  { id: "w07", title: "진달래꽃", author: "김소월", era: "1920년대", genre: "현대시", category: "modern",
    access: "free", price: 0, exam: false, popularity: 92, createdAt: "2026-11-08",
    summary: "이별의 상황에서 슬픔을 절제하는 화자의 태도가 핵심인 서정시." },
  { id: "w08", title: "서시", author: "윤동주", era: "1940년대", genre: "현대시", category: "modern",
    access: "premium", price: 2500, exam: true, popularity: 89, createdAt: "2026-11-06",
    summary: "부끄러움 없는 삶을 향한 성찰과 다짐을 담은 시." },
  { id: "w09", title: "향수", author: "정지용", era: "1920년대", genre: "현대시", category: "modern",
    access: "premium", price: 2500, exam: false, popularity: 76, createdAt: "2026-10-30",
    summary: "고향에 대한 그리움을 감각적 이미지로 형상화한 시." },
  { id: "w10", title: "메밀꽃 필 무렵", author: "이효석", era: "1930년대", genre: "현대소설", category: "modern",
    access: "premium", price: 3500, exam: true, popularity: 94, createdAt: "2026-11-11",
    summary: "장터길 서사와 서정적 묘사가 어우러진 단편소설." },
  { id: "w11", title: "운수 좋은 날", author: "현진건", era: "1920년대", genre: "현대소설", category: "modern",
    access: "free", price: 0, exam: false, popularity: 84, createdAt: "2026-10-25",
    summary: "반어적 제목과 상황의 아이러니가 두드러지는 단편소설." },
  { id: "w12", title: "사평역에서", author: "곽재구", era: "1980년대", genre: "현대시", category: "modern",
    access: "premium", price: 2500, exam: true, popularity: 78, createdAt: "2026-10-18",
    summary: "기차를 기다리는 사람들의 정서를 겨울 밤 풍경으로 그린 시." }
];
