CREATE TABLE CMP_SIZE
  (
    CODE NUMBER PRIMARY KEY, --기업 규모 코드
    NAME VARCHAR2(30)        --기업 규모 이름
  );
CREATE TABLE CMP
  (
    CODE          NUMBER PRIMARY KEY,               --기업 코드
    CMP_SIZE_CODE NUMBER REFERENCES CMP_SIZE(CODE), --기업 규모
    NAME          VARCHAR2(50) ,                    --기업명
    EMP_CNT       NUMBER ,                          --사원수
    CMP_SALES     NUMBER ,                          --매출액
    CMP_DATE      DATE ,                            --창립일
    TEL           VARCHAR2(20) ,                    --전화번호
    ADDR          VARCHAR2(200) ,                   --주소
    AVG_SAL       NUMBER DEFAULT 0,                 --평균연봉
    AVG_REVIEW    NUMBER DEFAULT 0                  --평균평점
  );
CREATE TABLE CMP_ADMIN
  (
    CODE     NUMBER PRIMARY KEY,                          --기업 관리자 코드
    CMP_CODE NUMBER UNIQUE NOT NULL REFERENCES CMP(CODE), --기업 코드(기업당 1개의 아이디만 생성 가능)
    ID       VARCHAR2(45),                                --기업 관리자 ID
    PASSWORD VARCHAR2(60)                                 --기업 관리자 비밀번호
  );
CREATE TABLE CMP_REVIEW
  (
    CODE           NUMBER PRIMARY KEY,
    CMP_CODE       NUMBER REFERENCES CMP(CODE), --기업코드
    RATING_SAL     NUMBER,                      --급여평점
    WORK_LIFE      NUMBER,                      --워라벨 평점
    RATING_CULTURE NUMBER,                      --사내문화 평점
    RATING_PROMO   NUMBER,                      --승진기회 평점
    RATING_CEO     NUMBER                       --경영진 평점
  );
CREATE TABLE EDU
  (
    CODE NUMBER PRIMARY KEY, --학력코드(학력별 정렬을 위함)
    NAME VARCHAR2(15)        --학력내용
  );
CREATE TABLE POSITION
  (
    CODE NUMBER PRIMARY KEY, --모집분야 코드
    NAME VARCHAR2(30)        --모집분야 내용
  );
CREATE TABLE MEMBER
  (
    CODE         NUMBER PRIMARY KEY,               --회원번호
    ID           VARCHAR2(45) UNIQUE NOT NULL ,    --회원 ID
    PASSWORD     VARCHAR2(60) NOT NULL,            --회원 비밀번호
    NAME         VARCHAR2(50),                     --회원 이름
    GENDER       NUMBER(1) ,                       --성별
    EDU_CODE     NUMBER REFERENCES EDU(CODE),      --학력 코드
    BIRTHDAY     DATE ,                            --생년월일
    TEL          VARCHAR2(50) ,                    --전화번호
    EMAIL        VARCHAR2(50) ,                    --이메일
    ADDR         VARCHAR2(200) ,                   --주소
    EXP_POSITION NUMBER REFERENCES POSITION(CODE), --경력분야
    EXP          NUMBER ,                          --경력년수
    LANG         VARCHAR2(50),                     --외국어 능력
    LOGIN        NUMBER(1) DEFAULT 0,              --로그인 여부
  );
CREATE TABLE JOB
  (
    CODE          NUMBER PRIMARY KEY,               --공고번호
    CMP_CODE      NUMBER REFERENCES CMP(CODE),      --기업코드
    POSITION_CODE NUMBER REFERENCES POSITION(CODE), --모집분야
    EDU_CODE      NUMBER REFERENCES EDU(CODE),      --요구 학력
    EXP           NUMBER ,                          --요구 경력
    SAL           NUMBER                            --초봉
  );
CREATE TABLE APPLY
  (
    MEMBER_CODE NUMBER REFERENCES MEMBER(CODE),             --지원한 회원코드
    JOB_CODE    NUMBER REFERENCES JOB(CODE),                --지원한 공고번호
    CONSTRAINT PK_APPLY PRIMARY KEY (MEMBER_CODE, JOB_CODE) --중복지원 불가
  );
CREATE TABLE BOOKMARK_CMP
  (
    MEMBER_CODE NUMBER REFERENCES MEMBER(CODE),                    --관심기업 지정한 회원 코드
    CMP_CODE    NUMBER REFERENCES CMP(CODE),                       --관심있는 기업 코드
    CONSTRAINT PK_BOOKMARK_CMP PRIMARY KEY (MEMBER_CODE, CMP_CODE) --관심기업 중복 불가
  );
CREATE TABLE BOOKMARK_JOB
  (
    MEMBER_CODE NUMBER REFERENCES MEMBER(CODE),                    --관심공고 지정한 회원 코드
    JOB_CODE    NUMBER REFERENCES JOB(CODE),                       --관심있는 공고번호
    CONSTRAINT PK_BOOKMARK_JOB PRIMARY KEY (MEMBER_CODE, JOB_CODE) --관심공고 중복 불가
  );
CREATE TABLE NOTICE
  (
    CODE        NUMBER PRIMARY KEY,             --알림 번호
    MEMBER_CODE NUMBER REFERENCES MEMBER(CODE), --알림 전송될 멤버 번호
    NOTICE_MSG  VARCHAR2(1000)                  --알림 내용
  );
/
-----------------CMP 테이블 AVG_REVIEW 수정--------------------------
UPDATE CMP C
SET AVG_REVIEW =
  (SELECT (RATING_SAL + WORK_LIFE + RATING_CULTURE + RATING_PROMO+ RATING_CEO)/5 AS AVG_REVIEW
  FROM CMP_REVIEW
  WHERE CMP_CODE =C.CODE
  )
  -------------------------------------------------------------------
  /
  ALTER TABLE MEMBER
  ADD LOGIN NUMBER(1) DEFAULT 0;
SELECT * FROM CMP;
SELECT * FROM CMP_REVIEW;
SELECT * FROM EDU;
SELECT * FROM MEMBER;
SELECT * FROM JOB;
SELECT * FROM APPLY;
SELECT * FROM BOOKMARK_CMP;
SELECT * FROM BOOKMARK_JOB;
SELECT * FROM NOTICE;
DROP TABLE NOTICE;
DROP TABLE BOOKMARK_JOB;
DROP TABLE BOOKMARK_CMP;
DROP TABLE APPLY;
DROP TABLE JOB;
DROP TABLE POSITION;
DROP TABLE MEMBER;
DROP TABLE EDU;
DROP TABLE CMP_REVIEW;
DROP TABLE CMP_ADMIN;
DROP TABLE CMP;
DROP TABLE CMP_SIZE;
DELETE FROM MEMBER;
DELETE FROM APPLY;
SELECT * FROM position;
SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'CMP';
SELECT * FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME ='SYS_C007889';
ALTER TABLE CMP RENAME column cmp_cnt TO EMP_CNT;
SELECT * FROM MEMBER;
DELETE FROM MEMBER;