-- ============================================================
-- 문학연구소 seed.sql (4단계)  — 화면 확인용 '샘플' 데이터
-- schema.sql 을 먼저 실행한 뒤 실행하세요. 여러 번 실행해도 안전합니다.
-- 아래 내용(가격, 인기 점수, 기출 표시, 분석 문장)은 샘플이며,
-- 판매용 자료는 직접 검수한 내용으로 교체하세요.
-- ============================================================

insert into public.works (slug, title, author, era, genre, category_id, summary, access, price, is_exam, is_published, popularity, created_at) values
  ('seongsan-byeolgok', '성산별곡', '정철', '조선 전기', '가사', (select id from public.categories where slug='classic'), '성산의 자연 속 삶과 임금에 대한 그리움을 함께 노래한 가사 작품.', 'premium', 3000, true, true, 98, '2026-11-10'),
  ('tangungga', '탄궁가', '박인로', '조선 후기', '가사', (select id from public.categories where slug='classic'), '궁핍한 생활 속에서도 안분지족의 자세를 드러내는 가사 작품.', 'premium', 3000, true, true, 95, '2026-11-09'),
  ('gwandong-byeolgok', '관동별곡', '정철', '조선 전기', '가사', (select id from public.categories where slug='classic'), '관동 지방의 명승을 유람하며 느낀 감흥과 선정(善政)의 포부를 담은 기행 가사.', 'free', 0, false, true, 90, '2026-11-05'),
  ('samiingok', '사미인곡', '정철', '조선 전기', '가사', (select id from public.categories where slug='classic'), '임금을 향한 그리움을 임을 그리는 여인의 목소리로 표현한 작품.', 'premium', 3000, true, true, 88, '2026-11-02'),
  ('nuhangsa', '누항사', '박인로', '조선 후기', '가사', (select id from public.categories where slug='classic'), '가난한 선비의 현실 고민과 안빈낙도의 다짐을 그린 가사.', 'premium', 3000, false, true, 80, '2026-10-28'),
  ('gyuwonga', '규원가', '허난설헌(전승)', '조선 중기', '가사', (select id from public.categories where slug='classic'), '규방 여인의 외로움과 원망을 노래한 규방 가사.', 'free', 0, false, true, 72, '2026-10-20'),
  ('jindallaekkot', '진달래꽃', '김소월', '1920년대', '현대시', (select id from public.categories where slug='modern'), '이별의 상황에서 슬픔을 절제하는 화자의 태도가 핵심인 서정시.', 'free', 0, false, true, 92, '2026-11-08'),
  ('seosi', '서시', '윤동주', '1940년대', '현대시', (select id from public.categories where slug='modern'), '부끄러움 없는 삶을 향한 성찰과 다짐을 담은 시.', 'premium', 2500, true, true, 89, '2026-11-06'),
  ('hyangsu', '향수', '정지용', '1920년대', '현대시', (select id from public.categories where slug='modern'), '고향에 대한 그리움을 감각적 이미지로 형상화한 시.', 'premium', 2500, false, true, 76, '2026-10-30'),
  ('memilkkot-pil-muryeop', '메밀꽃 필 무렵', '이효석', '1930년대', '현대소설', (select id from public.categories where slug='modern'), '장터길 서사와 서정적 묘사가 어우러진 단편소설.', 'premium', 3500, true, true, 94, '2026-11-11'),
  ('unsu-joeun-nal', '운수 좋은 날', '현진건', '1920년대', '현대소설', (select id from public.categories where slug='modern'), '반어적 제목과 상황의 아이러니가 두드러지는 단편소설.', 'free', 0, false, true, 84, '2026-10-25'),
  ('sapyeongyeoge-seo', '사평역에서', '곽재구', '1980년대', '현대시', (select id from public.categories where slug='modern'), '기차를 기다리는 사람들의 정서를 겨울 밤 풍경으로 그린 시.', 'premium', 2500, true, true, 78, '2026-10-18')
on conflict (slug) do nothing;

-- 분석 샘플: 진달래꽃 (무료)
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'info', $j$[["작품명","진달래꽃"],["작가","김소월"],["갈래","현대시, 서정시, 민요시"],["성격","서정적, 애상적, 민요적"],["운율","3음보 율격 (외형률)"],["제재","임과의 이별"],["주제","이별의 슬픔을 참고 견디는 사랑"],["발표","1922년 「개벽」 / 1925년 시집 『진달래꽃』 수록"]]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'author', $j$["김소월(1902~1934)은 평안북도 출신의 시인으로, 본명은 김정식입니다. 스승 김억의 영향 아래 시를 쓰기 시작했고, 전통적인 민요 율격과 향토적 소재를 바탕으로 이별과 그리움, 한(恨)의 정서를 서정적으로 노래했습니다.","대표작으로 「진달래꽃」, 「초혼」, 「산유화」, 「먼 후일」 등이 있으며, 생전에 낸 유일한 시집이 『진달래꽃』(1925)입니다."]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'background', $j$["1920년대 일제강점기에 발표된 작품입니다. 표면적으로는 사랑하는 임과의 이별을 다루지만, 상실감이 지배하던 당대 현실과 연결해 '임'을 조국이나 이상적 존재로 읽는 해석도 있습니다.","수능에서는 특정 해석을 단정하기보다, 작품에 드러난 화자의 상황과 정서를 근거로 감상하는 방식이 요구됩니다."]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'original', $j$[["나 보기가 역겨워","가실 때에는","말없이 고이 보내 드리오리다"],["영변에 약산","진달래꽃","아름 따다 가실 길에 뿌리오리다"],["가시는 걸음 걸음","놓인 그 꽃을","사뿐히 즈려밟고 가시옵소서"],["나 보기가 역겨워","가실 때에는","죽어도 아니 눈물 흘리오리다"]]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'modern', $j$[{"o":"나 보기가 역겨워","m":"나를 보는 것이 싫어서"},{"o":"가실 때에는","m":"떠나실 때에는"},{"o":"말없이 고이 보내 드리오리다","m":"아무 말 없이 곱게 보내 드리겠습니다"},{"o":"영변에 약산","m":"평안북도 영변에 있는 약산(진달래로 이름난 산)"},{"o":"아름 따다 가실 길에 뿌리오리다","m":"한 아름 따다가 가시는 길에 뿌려 드리겠습니다"},{"o":"가시는 걸음 걸음 놓인 그 꽃을","m":"가시는 걸음걸음마다 놓인 그 꽃을"},{"o":"사뿐히 즈려밟고 가시옵소서","m":"가볍게 지그시 밟고 가십시오"},{"o":"죽어도 아니 눈물 흘리오리다","m":"죽어도 눈물을 흘리지 않겠습니다"}]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'analysis', $j$[{"q":"1연 — 나 보기가 역겨워 / 가실 때에는 / 말없이 고이 보내 드리오리다","a":"'-ㄹ 때에는'으로 이별을 가정하여 제시합니다. 임이 떠나려는 이유가 '역겨워'라는, 화자에게 상처가 되는 것인데도 화자는 '말없이 고이' 보내겠다고 하여 감정을 누르는 태도를 보입니다. '-오리다'는 화자의 의지를 나타내는 종결 어미입니다."},{"q":"2연 — 영변에 약산 / 진달래꽃 / 아름 따다 가실 길에 뿌리오리다","a":"구체적 공간(영변 약산)과 소재(진달래꽃)가 등장합니다. '아름'은 두 팔로 안을 만큼의 분량이라는 뜻이므로 정성과 헌신의 크기를 보여 줍니다. 진달래꽃은 화자의 사랑을 담은 사물이자 임에게 건네는 축복의 표지로 읽힙니다."},{"q":"3연 — 가시는 걸음 걸음 / 놓인 그 꽃을 / 사뿐히 즈려밟고 가시옵소서","a":"화자의 사랑이 담긴 꽃을 밟고 가라고 하는 것은 자신의 아픔을 감수하는 희생적 태도입니다. '가시옵소서'는 높임의 기원형 표현으로 임을 향한 존중을 드러냅니다."},{"q":"4연 — 나 보기가 역겨워 / 가실 때에는 / 죽어도 아니 눈물 흘리오리다","a":"1연을 반복하며 마지막 행만 바뀝니다. '죽어도 아니'라는 강한 부정은 눈물을 흘리지 않겠다는 다짐이지만, 그렇게까지 강조해야 할 만큼 큰 슬픔이 있다는 것을 역설적으로 보여 줍니다."}]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'attitude', $j$["이별을 가정하는 화자는 임을 원망하거나 붙잡지 않고 담담히 보내겠다고 말합니다. 그러나 이는 슬픔이 없어서가 아니라, 슬픔을 참고 견디며 임의 앞길을 축복하려는 인종(忍從)과 헌신의 태도입니다.","정서의 흐름은 '표면의 담담함 → 꽃을 뿌리는 정성 → 아픔을 감수하는 희생 → 눈물을 참겠다는 다짐'으로 점차 고조되며, 그 밑바탕에 이별의 슬픔이 깔려 있습니다."]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'structure', $j$[{"part":"1연 (기)","desc":"이별 상황의 가정과 임을 말없이 보내겠다는 수용의 태도"},{"part":"2연 (승)","desc":"진달래꽃을 따서 임의 길에 뿌리겠다는 정성"},{"part":"3연 (전)","desc":"꽃을 밟고 가시라는 희생적 사랑과 축원"},{"part":"4연 (결)","desc":"1연을 반복하되 눈물을 참겠다는 다짐으로 정서를 고조"}]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'theme', $j$["이별의 슬픔을 겉으로 드러내지 않고 참아 내며 임을 축복하는 희생적 사랑, 곧 이별의 정한(情恨)과 그 승화입니다."]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'expression', $j$["수미상관(1연과 4연의 반복)으로 정서를 강조하고 구조적 안정감을 줍니다.","'-오리다', '-옵소서' 등 경어체 종결로 임에 대한 존중과 의지를 나타냅니다.","역설적 표현: 눈물을 흘리지 않겠다는 말이 오히려 큰 슬픔을 드러냅니다.","진달래꽃이라는 자연물을 통해 화자의 사랑과 정서를 간접적으로 표현합니다.","3음보의 민요적 율격으로 운율을 형성합니다."]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'points', $j$["화자의 정서를 드러내는 방식: 감정을 직접 토로하지 않고 절제하며 역설로 드러냄","수미상관의 효과: 정서의 강조와 안정감. 단, 4연은 마지막 행이 달라지므로 '완전히 같다'고 판단하면 오답","'진달래꽃'의 기능: 이별의 정서를 환기하는 동시에 화자의 사랑과 축복을 담은 소재","'가정적 상황'과 '실제 이별 장면'을 구분: 실제로 이별이 일어나는 장면이 아니라 가정","'즈려밟고', '아름' 등 시어의 의미를 묻는 어휘 문제"]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'choices', $j$[{"tag":"예시(실제 기출 아님)","t":"수미상관의 구조를 활용하여 화자의 정서를 강조하고 있다.","ok":true,"why":"1연과 4연이 비슷한 구조로 반복되며 이별의 정서를 강조하므로 적절합니다."},{"tag":"예시(실제 기출 아님)","t":"자연물을 통해 이별에 대한 화자의 마음을 간접적으로 드러내고 있다.","ok":true,"why":"진달래꽃을 뿌리고 밟게 하는 행위로 화자의 사랑과 슬픔이 드러나므로 적절합니다."},{"tag":"예시(실제 기출 아님)","t":"공간의 이동에 따라 화자의 정서가 변화하고 있다.","ok":false,"why":"'영변에 약산'은 배경 제시이며 화자가 이동하지 않습니다. 공간 이동에 따른 시상 전개가 아니므로 오답입니다."},{"tag":"예시(실제 기출 아님)","t":"화자는 임에 대한 원망을 점차 냉소적으로 표출하고 있다.","ok":false,"why":"화자는 끝까지 임을 존대하고 축복하는 태도를 유지합니다. 냉소적 표출이라는 판단은 근거가 없어 오답입니다."},{"tag":"예시(실제 기출 아님)","t":"명령형 어미를 반복하여 청자의 행동을 강하게 요구하고 있다.","ok":false,"why":"'-오리다'는 화자의 의지를 나타내는 어미이고, '가시옵소서'는 높임의 기원이어서 강하게 요구하는 어조가 아닙니다. 오답입니다."}]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'compare', $j$[{"work":"「가시리」 (고려가요)","text":"둘 다 이별의 상황에서 임을 보내는 화자의 정서를 다룹니다. 「가시리」는 임을 보내면서도 다시 돌아오기를 바라는 애원과 체념이 두드러지는 반면, 「진달래꽃」은 슬픔을 참고 임을 축복하는 적극적인 인종의 태도가 강조됩니다."},{"work":"「송인」 (정지상)","text":"「송인」은 이별의 슬픔을 눈물이 강물을 더한다는 과장된 표현으로 직접 드러냅니다. 「진달래꽃」은 눈물을 참겠다는 절제와 역설로 슬픔을 드러내므로 정서 표현 방식이 대비됩니다."}]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'summary', $j$["갈래: 현대시(서정시, 민요시) / 운율: 3음보 / 구조: 4연, 수미상관","상황: 임이 떠나는 상황을 가정, 화자는 말없이 보내고 꽃을 뿌리겠다고 함","정서: 슬픔을 참는 인종, 희생적 사랑, 임에 대한 축복","핵심 표현: 역설('죽어도 아니 눈물'), 수미상관, 진달래꽃(자연물), 경어체 종결","함정: 공간 이동, 냉소·원망, 4연이 1연과 '완전히 같다'는 판단"]$j$::jsonb, false from public.works where slug='jindallaekkot'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();

-- 분석 샘플: 성산별곡 (프리미엄)
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'info', $j$[["작품명","성산별곡"],["작가","정철"],["갈래","가사 (강호가사)"],["시대","조선 전기"],["성격","서정적, 예찬적"],["제재","성산(星山)의 사계절 풍경과 그 속의 삶"],["표기","국문 (음보 중심의 연속체 율문)"]]$j$::jsonb, true from public.works where slug='seongsan-byeolgok'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'author', $j$["정철(1536~1593)은 조선 중기 문신이자 시인으로, 가사와 시조 모두에서 뛰어난 작품을 남겼습니다. 「관동별곡」, 「사미인곡」, 「속미인곡」과 함께 「성산별곡」이 그의 대표 가사로 꼽힙니다. 호는 송강입니다."]$j$::jsonb, true from public.works where slug='seongsan-byeolgok'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'background', $j$["정철이 전라도 담양(창평) 성산 일대에서 지내던 젊은 시절에 지은 것으로 전해지는 작품입니다. 성산의 자연과 그곳에 머물던 인물의 삶을 노래합니다.","정확한 창작 시기와 세부 배경에는 견해 차이가 있으므로, 이 항목은 판매 전에 교재·논문으로 직접 검수해야 합니다."]$j$::jsonb, true from public.works where slug='seongsan-byeolgok'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();
insert into public.analyses (work_id, section_key, body, is_preview)
select id, 'theme', $j$["성산의 사계절 풍경과 그 속에서 누리는 풍류를 예찬하는 것이 중심입니다."]$j$::jsonb, true from public.works where slug='seongsan-byeolgok'
on conflict (work_id, section_key) do update set body=excluded.body, is_preview=excluded.is_preview, updated_at=now();

