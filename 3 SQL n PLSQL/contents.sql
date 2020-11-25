SET serveroutput ON;
/
DECLARE
  CURSOR cmp_cursor
  IS
    SELECT c.name, s.name AS cmp_size_name, c.emp_cnt, c.cmp_sales, c.cmp_date, c.tel, c.addr, c.avg_sal, c.avg_review
    FROM cmp c, cmp_size s
    WHERE c.cmp_size_code = s.code
    AND s.name LIKE '%&기업규모%'
    AND c.addr LIKE '%&희망지역%'
    AND c.avg_sal    >= '&희망연봉'
    AND c.avg_review >= '&평점';
  cmp_name cmp.NAME%TYPE;
  cmp_size_name cmp_size.name%TYPE;
  emp_cnt cmp.emp_cnt%TYPE;
  cmp_sales cmp.cmp_sales%TYPE;
  cmp_date cmp.cmp_date%TYPE;
  cmp_tel cmp.tel%TYPE;
  cmp_addr cmp.addr%TYPE;
  cmp_avg_sal cmp.avg_sal%TYPE;
  cmp_avg_review cmp.avg_review%TYPE;
BEGIN
  OPEN cmp_cursor;
  dbms_output.put_line('회사코드  회사이름  회사규모  사원수  매출액  설립일  연락처  지역  평균연봉  ★평균평점');
  dbms_output.put_line('==================================================================================');
  LOOP
    FETCH cmp_cursor
    INTO cmp_name, cmp_size_name, emp_cnt, cmp_sales, cmp_date, cmp_tel, cmp_addr, cmp_avg_sal, cmp_avg_review;
    EXIT
  WHEN cmp_cursor%notfound;
    DBMS_OUTPUT.PUT_LINE(cmp_name||' | '||cmp_size_name||' | '||emp_cnt||' | '||cmp_sales||' | '|| cmp_date||' | '||cmp_tel||' | '||cmp_addr||' | '||cmp_avg_sal||' | ★'||cmp_avg_review);
  END LOOP;
  CLOSE cmp_cursor;
END;
/
/* 요구사항 01 */
/*      회원이 원하는 기업 정보를 조회하기 위해
"기업 규모, 지역, 원하는 연봉" 검색조건을
화면에서 입력받아 원하는 기업의 정보 출력    */
/*  함수 내부의 SELECT into절의 경우
단일행만 받는 변수 이기에 0건 또는 2건 이상의 데이터를 추출하면 에러가 발생.
따라서 커서를 만들어 WHERE 조건절에
"회사규모", "회원이 선호하는 지역", "원하는 연봉 조건" 그리고 "회사의 평균평점"을 입력받아
해당하는 조건에 맞는 회사들을 뽑아준다    */
/
/* 요구사항 02 */
/*    기업에서 인재탐색을 위해 원하는 조건의 회원을 조회
예시) 남성이며 경력이 있고, 영어 가능자, 대졸 이상인 회원을 조회    */
DECLARE
  mname member.name%TYPE;
  mgender member.gender%TYPE;
  mposition position.name%TYPE;
  mexp member.exp%TYPE;
  mlang member.lang%TYPE;
  meduname edu.name%TYPE;
  
  CURSOR member_cursor
  IS
    SELECT m.name, m.gender, p.name AS position_name, m.exp, m.lang, e.name AS edu_name
    FROM member m, edu e, position p
    WHERE m.edu_code   = e.code
    AND m.exp_position = p.code
    AND m.gender       ='&성별'
    AND m.exp         >= '&경력년수'
    AND m.lang LIKE '%&가능외국어%'
    AND m.edu_code >= (select code from edu where name = '&학력')
    ORDER BY e.code;

BEGIN
  DBMS_OUTPUT.PUT_LINE('이름     성별     경력(년)          외국어    학력');
  DBMS_OUTPUT.PUT_LINE('===============================================');
  OPEN member_cursor;
  LOOP
    FETCH member_cursor INTO mname, mgender, mposition, mexp, mlang, meduname;
    EXIT
  WHEN member_cursor%notfound;
    DBMS_OUTPUT.PUT_LINE(mname||'    '||mgender||'      '||mposition||'  '||mexp||'년'||'       '||mlang||'     '||meduname);
  END LOOP;
  CLOSE member_cursor;
END;
/

-----------------------------------------------------------------------------------쿼리문
/* 요구사항 03 */
/*    화면에서 원하는 초봉을 입력받아 그 이상인 채용공고  조회   */
SELECT C.NAME 회사이름, P.NAME 모집분야, J.EXP||'년' 요구경력,
  (SELECT NAME FROM EDU WHERE CODE = J.EDU_CODE) 요구학력, J.SAL 초봉
FROM JOB J, CMP C, POSITION P
WHERE J.CMP_CODE = C.CODE
AND J.POSITION_CODE = P.CODE
AND J.SAL       >= '&희망초봉'
ORDER BY J.SAL;

/* 요구사항 04 */
/*    회원의 지역별 연령별 분포도를 확인하고 연령별 합계 통계를 조회
decode를 사용 substr로 주소의 지역만 뽑아서 없으면 전체합계가 뜨고 있으면 해당하는 지역이 열로 나온다
from 절에 inline쿼리로 현재 날짜와 입력된 생일의 달을 months_between으로 계산해서 12로 나누면 나이가 나오고 age로 alias를 지정해서
case문에서 쓸 수 있게 만들었다
case문을 이용해서 비교 후 조건에 맞으면 count를 해서 결과물 출력     */
SELECT DECODE(SUBSTR(addr,1,2),NULL,'전체합계',SUBSTR(addr,1,2)) 지역,
  COUNT( CASE WHEN age < 20 THEN 1 END) "10대",
  COUNT(CASE WHEN age BETWEEN 20 AND 29 THEN 1 END ) "20대",
  COUNT(CASE WHEN age BETWEEN 30 AND 39 THEN 1 END ) "30대",
  COUNT( CASE WHEN age >= 40 THEN 1 END) "40대 이상"
FROM
  (SELECT DISTINCT TRUNC(months_between(SYSDATE, birthday)/12) age ,
    addr
  FROM member)
GROUP BY ROLLUP(SUBSTR(addr,1,2));
select * from member;
/* 요구사항 05 */
/*    화면에서 지원자 이름을 입력받아, 해당 회원이 지원한 채용공고 목록 조회(지원자용)   */
SELECT DISTINCT m.name 이름, c.name 회사명, 
  (select name from position where code = J.POSITION_code) 모집분야, 
  (select name from cmp_size where code = C.cmp_size_code) AS 규모, j.sal 초봉, c.emp_cnt 사원수, '☎'||NVL(c.tel,'-') 회사연락처,
  c.addr 회사주소,(SELECT COUNT(*) FROM APPLY WHERE JOB_CODE = J.CODE) 지원자수
FROM member m, apply a, job j, cmp c
WHERE A.member_code = m.code
AND j.cmp_code      = c.code
AND j.code          = A.job_code
AND m.NAME          = '&이름'
ORDER BY j.sal DESC ;
SELECT J.CODE,
  ( SELECT COUNT(*) FROM APPLY WHERE JOB_CODE = J.CODE) 지원자수
FROM JOB J;

/* 요구사항 06 */
/*    평균 평점이 3.7점 이상인 기업 조회   */
SELECT name AS "기업이름", AVG(cr.rating_sal) "연봉", AVG(cr.WORK_LIFE) "워라밸", AVG(cr.RATING_CULTURE) "회사문화",
  AVG(cr.RATING_PROMO) "승진기회", AVG(cr.RATING_CEO) "경영진", '★ '||c.avg_review AS "평균평점"
FROM cmp c, cmp_review cr
WHERE cr.cmp_code = c.code
AND c.avg_review  > 3.7
GROUP BY name, c.avg_review;

/* 요구사항 07 */
/*    기업이 게시한 채용공고의 지원자 목록 조회하기(기업명 부분 입력 가능) (기업용)
화면에서 기업명을 입력받아야 함(키워드 입력)     */
SELECT c.name 기업명,
  (select name from position where code = j.position_code) 모집부분,
  m.name 지원자명,
  TRUNC(months_between(SYSDATE, m.birthday)/12)||'살' AS "나이",
  (SELECT name FROM edu WHERE code = m.EDU_CODE) AS 학력,
  (select name from position where code = m.exp_position)
  ||DECODE(m.exp,0,'경력 없음',' '||m.exp||'년') 지원자경력,
  NVL(m.lang,'X') 가능외국어, SUBSTR(m.addr,1,2) 거주지역, '☎'||m.tel 연락처, m.email 이메일
FROM cmp c, member m, apply a, job j
WHERE a.job_code  = j.code
AND a.member_code = m.code
AND j.cmp_code    = c.code
AND c.NAME LIKE '%&회사이름%' --기업 이름
ORDER BY m.exp DESC;
;

/* 요구사항 08 */
/*    해당 기업의 채용 공고에 대한 경력 분야별, 경력 년수별 지원자 통계 조회 (기업용)
화면에서 기업명을 입력받아야 함(키워드 입력)     */
SELECT nvl(m.exp_position,'경력없음') 경력분야,
  count(CASE WHEN m.exp = 0 THEN 1 END) "경력 없음",
  count(CASE WHEN m.exp BETWEEN 1 AND 2 THEN 1 END) "경력 1~2년",
  count(CASE WHEN m.exp BETWEEN 3 AND 5 THEN 1 END) "경력 3~5년",
  count(CASE WHEN m.exp >= 6 THEN 1 END) "경력 6년 이상"
FROM
  (SELECT p.name AS exp_position, mb.exp, mb.code
    FROM MEMBER mb LEFT JOIN position p ON mb.exp_position = p.code) m,
  APPLY A, JOB j, cmp c
WHERE m.code   = A.member_code
AND A.job_code = j.code
AND j.cmp_code = c.code
AND c.name LIKE '%&회사이름%' --기업 이름
GROUP BY nvl(m.exp_position,'경력없음');
;
/* 요구사항 09 */
/*    회원이 관심 기업, 관심 공고 등록/해제하기    */
-- 패키지 생성
CREATE OR REPLACE PACKAGE bookmark
AS
  -- 프로시저 4개(
  PROCEDURE bookmark_cmp_insert( --관심 기업 등록
      vmember_code bookmark_cmp.member_code%TYPE,
      vcmp_code bookmark_cmp.cmp_code%TYPE);
  PROCEDURE bookmark_cmp_delete( -- 관심 기업 삭제
      vmember_code bookmark_cmp.member_code%TYPE,
      vcmp_code bookmark_cmp.cmp_code%TYPE);
      
  PROCEDURE bookmark_job_insert( --관심 공고 등록
      vmember_code bookmark_job.member_code%TYPE,
      vjob_code bookmark_job.job_code%TYPE);
  PROCEDURE bookmark_job_delete( --관심 공고 삭제
      vmember_code bookmark_job.member_code%TYPE,
      vjob_code bookmark_job.job_code%TYPE);
END bookmark;
/
-- 패키지 본문
CREATE OR REPLACE PACKAGE BODY bookmark
AS
  -- 회원번호, 기업번호를 입력받아 bookmark_cmp 테이블에 관심기업 정보 저장, CODE값은 +1씩 자동 증가
  PROCEDURE bookmark_cmp_insert(
      vmember_code bookmark_cmp.member_code%TYPE ,
      vcmp_code bookmark_cmp.cmp_code%TYPE)
  IS
  BEGIN
    INSERT INTO bookmark_cmp VALUES (vmember_code, vcmp_code);
    IF(SQL%rowcount>0) THEN
      DBMS_OUTPUT.PUT_LINE('관심 기업으로 등록되었습니다.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('일치하는 내용이 없습니다.');
    END IF;
  END bookmark_cmp_insert;
-- CODE를 입력받아 해당되는 BOOKMARK_CMP 행 삭제
  PROCEDURE bookmark_cmp_delete
    (
      vmember_code bookmark_cmp.member_code%TYPE ,
      vcmp_code bookmark_cmp.cmp_code%TYPE
    )
  IS
  BEGIN
    DELETE FROM bookmark_cmp WHERE member_code = vmember_code and cmp_code = vcmp_code;
    IF(SQL%rowcount>0) THEN
      DBMS_OUTPUT.PUT_LINE('삭제 되었습니다.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('일치하는 내용이 없습니다.');
    END IF;
  END bookmark_cmp_delete;
-- MEMBER_CODE, JOB_CODE를 입력받아 인서트, CODE값은 +1씩 자동 증가
  PROCEDURE bookmark_job_insert(
      vmember_code bookmark_job.member_code%TYPE,
      vjob_code bookmark_job.job_code%TYPE)
  IS
  BEGIN
    INSERT
    INTO bookmark_job VALUES
      (
        vmember_code,
        vjob_code
      );
  END bookmark_job_insert;
-- CODE를 입력받아 해당되는 BOOKMARK_JOB 행 삭제
  PROCEDURE bookmark_job_delete
    (
      vmember_code bookmark_job.member_code%TYPE,
      vjob_code bookmark_job.job_code%TYPE
    )
  IS
  BEGIN
    DELETE FROM bookmark_job WHERE member_code = vmember_code AND job_code = vjob_code;
    IF (SQL%rowcount>0) THEN
      DBMS_OUTPUT.PUT_LINE('삭제 되었습니다.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('일치하는 내용이 없습니다.');
    END IF;
  END bookmark_job_delete;
END bookmark;
/
-- 사용 예시(드래그해서 실행) --
SELECT * FROM bookmark_cmp;
/
EXEC bookmark.bookmark_cmp_insert(5,12); --(MEMBER_CODE, CMP_CODE)
EXEC bookmark.bookmark_cmp_delete(1,1); --(MEMBER_CODE, CMP_CODE)
EXEC bookmark.bookmark_job_insert(5,52); --(MEMBER_CODE, JOB_CODE)
EXEC bookmark.bookmark_job_delete(1,2); --(MEMBER_CODE, JOB_CODE)
/
SELECT * FROM bookmark_cmp;
SELECT * FROM bookmark_job;
/
/* 요구사항 10 */
/*    회원이 기업에 대한 평점 입력 시, CMP의 AVG_REVIEW 컬럼에 전체 평균 평점 반영    */
/*    익명성 보장을 위해 회원 정보는 입력되지 않아야함     */
CREATE OR REPLACE TRIGGER t_cmp_review AFTER
  INSERT ON cmp_review FOR EACH ROW BEGIN
  UPDATE cmp
  SET avg_review = nvl2(avg_review, (avg_review + ((:NEW.rating_sal + :NEW.work_life + :NEW.rating_culture + :NEW.rating_promo + :NEW.rating_ceo) / 5))/2 --
    , NVL(avg_review,0)                         + ( :NEW.rating_sal + :NEW.work_life + :NEW.rating_culture + :NEW.rating_promo + :NEW.rating_ceo) / 5)
  WHERE code = :NEW.cmp_code;
  DBMS_OUTPUT.PUT_LINE('CMP에 평점이 반영되었습니다.');
END ;
/
SELECT * FROM cmp WHERE name = '나경컴퍼니';
INSERT INTO cmp_review VALUES ((SELECT NVL(MAX(code),0)+1 FROM cmp_review),12,5,5,5,5,5);


--AVG가 NULL인 경우
INSERT INTO cmp_review VALUES ((SELECT NVL(MAX(code),0)+1 FROM cmp_review),20,0,0,0,0,0);
SELECT code, NAME, avg_review FROM cmp WHERE code = 20;
INSERT INTO cmp_review VALUES ((SELECT NVL(MAX(code),0)+1 FROM cmp_review),1,1,1,1,1,1);
SELECT code, NAME, avg_review FROM cmp WHERE code = 1;
/
/* 새로운 공고 등록 알림 */
/*   회원이 등록한 관심기업에서 새로운 공고가 올라오면, 해당 회원에게 보낼 알림메시지 저장    */
/*   예시) (주)OOO에서 새로운 공고가 올라왔습니다.     */
CREATE OR REPLACE TRIGGER add_notice AFTER
  INSERT ON JOB FOR EACH ROW
  DECLARE
  CURSOR cursor1
  IS
  SELECT bc.member_code, bc.cmp_code, c.NAME
  FROM bookmark_cmp bc, cmp c
  WHERE bc.cmp_code = c.code
  AND :NEW.cmp_code = bc.cmp_code;
  BEGIN
    IF(SQL%rowcount=0) THEN
      INSERT INTO JOB VALUES ((SELECT NVL(MAX(code),0)+1 FROM JOB), 
        :NEW.cmp_code, :NEW.position_code, :NEW.edu_code, :NEW.exp, :NEW.sal);
    ELSE
      FOR vnotice IN cursor1
      LOOP
        EXIT
      WHEN cursor1%notfound;
        INSERT INTO notice VALUES ((SELECT NVL(MAX(code),0)+1 FROM notice),
        vnotice.member_code, vnotice.NAME||'에서 새로운 공고가 올라왔습니다.');
        DBMS_OUTPUT.PUT_LINE('NOTICE에 새로운 알림이 추가 되었습니다.');
      END LOOP;
    END IF;
  END;
  /
  select * from job;
  SELECT * FROM notice;
  SELECT * FROM bookmark_cmp;
  -- 새로운 공고 등록 (CMP_NO = 12 (나경컴퍼니))
  INSERT INTO job VALUES ((SELECT NVL(MAX(code),0)+1 FROM job),12
  ,(select code from position where name = '마케팅'),3,1,3300);
  SELECT * FROM notice;