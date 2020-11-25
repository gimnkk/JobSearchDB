CREATE TABLE CMP_SIZE
  (
    CODE NUMBER PRIMARY KEY, --��� �Ը� �ڵ�
    NAME VARCHAR2(30)        --��� �Ը� �̸�
  );
CREATE TABLE CMP
  (
    CODE          NUMBER PRIMARY KEY,               --��� �ڵ�
    CMP_SIZE_CODE NUMBER REFERENCES CMP_SIZE(CODE), --��� �Ը�
    NAME          VARCHAR2(50) ,                    --�����
    EMP_CNT       NUMBER ,                          --�����
    CMP_SALES     NUMBER ,                          --�����
    CMP_DATE      DATE ,                            --â����
    TEL           VARCHAR2(20) ,                    --��ȭ��ȣ
    ADDR          VARCHAR2(200) ,                   --�ּ�
    AVG_SAL       NUMBER DEFAULT 0,                 --��տ���
    AVG_REVIEW    NUMBER DEFAULT 0                  --�������
  );
CREATE TABLE CMP_ADMIN
  (
    CODE     NUMBER PRIMARY KEY,                          --��� ������ �ڵ�
    CMP_CODE NUMBER UNIQUE NOT NULL REFERENCES CMP(CODE), --��� �ڵ�(����� 1���� ���̵� ���� ����)
    ID       VARCHAR2(45),                                --��� ������ ID
    PASSWORD VARCHAR2(60)                                 --��� ������ ��й�ȣ
  );
CREATE TABLE CMP_REVIEW
  (
    CODE           NUMBER PRIMARY KEY,
    CMP_CODE       NUMBER REFERENCES CMP(CODE), --����ڵ�
    RATING_SAL     NUMBER,                      --�޿�����
    WORK_LIFE      NUMBER,                      --���� ����
    RATING_CULTURE NUMBER,                      --�系��ȭ ����
    RATING_PROMO   NUMBER,                      --������ȸ ����
    RATING_CEO     NUMBER                       --�濵�� ����
  );
CREATE TABLE EDU
  (
    CODE NUMBER PRIMARY KEY, --�з��ڵ�(�зº� ������ ����)
    NAME VARCHAR2(15)        --�з³���
  );
CREATE TABLE POSITION
  (
    CODE NUMBER PRIMARY KEY, --�����о� �ڵ�
    NAME VARCHAR2(30)        --�����о� ����
  );
CREATE TABLE MEMBER
  (
    CODE         NUMBER PRIMARY KEY,               --ȸ����ȣ
    ID           VARCHAR2(45) UNIQUE NOT NULL ,    --ȸ�� ID
    PASSWORD     VARCHAR2(60) NOT NULL,            --ȸ�� ��й�ȣ
    NAME         VARCHAR2(50),                     --ȸ�� �̸�
    GENDER       NUMBER(1) ,                       --����
    EDU_CODE     NUMBER REFERENCES EDU(CODE),      --�з� �ڵ�
    BIRTHDAY     DATE ,                            --�������
    TEL          VARCHAR2(50) ,                    --��ȭ��ȣ
    EMAIL        VARCHAR2(50) ,                    --�̸���
    ADDR         VARCHAR2(200) ,                   --�ּ�
    EXP_POSITION NUMBER REFERENCES POSITION(CODE), --��ºо�
    EXP          NUMBER ,                          --��³��
    LANG         VARCHAR2(50),                     --�ܱ��� �ɷ�
    LOGIN        NUMBER(1) DEFAULT 0,              --�α��� ����
  );
CREATE TABLE JOB
  (
    CODE          NUMBER PRIMARY KEY,               --�����ȣ
    CMP_CODE      NUMBER REFERENCES CMP(CODE),      --����ڵ�
    POSITION_CODE NUMBER REFERENCES POSITION(CODE), --�����о�
    EDU_CODE      NUMBER REFERENCES EDU(CODE),      --�䱸 �з�
    EXP           NUMBER ,                          --�䱸 ���
    SAL           NUMBER                            --�ʺ�
  );
CREATE TABLE APPLY
  (
    MEMBER_CODE NUMBER REFERENCES MEMBER(CODE),             --������ ȸ���ڵ�
    JOB_CODE    NUMBER REFERENCES JOB(CODE),                --������ �����ȣ
    CONSTRAINT PK_APPLY PRIMARY KEY (MEMBER_CODE, JOB_CODE) --�ߺ����� �Ұ�
  );
CREATE TABLE BOOKMARK_CMP
  (
    MEMBER_CODE NUMBER REFERENCES MEMBER(CODE),                    --���ɱ�� ������ ȸ�� �ڵ�
    CMP_CODE    NUMBER REFERENCES CMP(CODE),                       --�����ִ� ��� �ڵ�
    CONSTRAINT PK_BOOKMARK_CMP PRIMARY KEY (MEMBER_CODE, CMP_CODE) --���ɱ�� �ߺ� �Ұ�
  );
CREATE TABLE BOOKMARK_JOB
  (
    MEMBER_CODE NUMBER REFERENCES MEMBER(CODE),                    --���ɰ��� ������ ȸ�� �ڵ�
    JOB_CODE    NUMBER REFERENCES JOB(CODE),                       --�����ִ� �����ȣ
    CONSTRAINT PK_BOOKMARK_JOB PRIMARY KEY (MEMBER_CODE, JOB_CODE) --���ɰ��� �ߺ� �Ұ�
  );
CREATE TABLE NOTICE
  (
    CODE        NUMBER PRIMARY KEY,             --�˸� ��ȣ
    MEMBER_CODE NUMBER REFERENCES MEMBER(CODE), --�˸� ���۵� ��� ��ȣ
    NOTICE_MSG  VARCHAR2(1000)                  --�˸� ����
  );
/
-----------------CMP ���̺� AVG_REVIEW ����--------------------------
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