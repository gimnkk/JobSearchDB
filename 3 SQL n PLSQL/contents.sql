SET serveroutput ON;
/
DECLARE
  CURSOR cmp_cursor
  IS
    SELECT c.name, s.name AS cmp_size_name, c.emp_cnt, c.cmp_sales, c.cmp_date, c.tel, c.addr, c.avg_sal, c.avg_review
    FROM cmp c, cmp_size s
    WHERE c.cmp_size_code = s.code
    AND s.name LIKE '%&����Ը�%'
    AND c.addr LIKE '%&�������%'
    AND c.avg_sal    >= '&�������'
    AND c.avg_review >= '&����';
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
  dbms_output.put_line('ȸ���ڵ�  ȸ���̸�  ȸ��Ը�  �����  �����  ������  ����ó  ����  ��տ���  ���������');
  dbms_output.put_line('==================================================================================');
  LOOP
    FETCH cmp_cursor
    INTO cmp_name, cmp_size_name, emp_cnt, cmp_sales, cmp_date, cmp_tel, cmp_addr, cmp_avg_sal, cmp_avg_review;
    EXIT
  WHEN cmp_cursor%notfound;
    DBMS_OUTPUT.PUT_LINE(cmp_name||' | '||cmp_size_name||' | '||emp_cnt||' | '||cmp_sales||' | '|| cmp_date||' | '||cmp_tel||' | '||cmp_addr||' | '||cmp_avg_sal||' | ��'||cmp_avg_review);
  END LOOP;
  CLOSE cmp_cursor;
END;
/
/* �䱸���� 01 */
/*      ȸ���� ���ϴ� ��� ������ ��ȸ�ϱ� ����
"��� �Ը�, ����, ���ϴ� ����" �˻�������
ȭ�鿡�� �Է¹޾� ���ϴ� ����� ���� ���    */
/*  �Լ� ������ SELECT into���� ���
�����ุ �޴� ���� �̱⿡ 0�� �Ǵ� 2�� �̻��� �����͸� �����ϸ� ������ �߻�.
���� Ŀ���� ����� WHERE ��������
"ȸ��Ը�", "ȸ���� ��ȣ�ϴ� ����", "���ϴ� ���� ����" �׸��� "ȸ���� �������"�� �Է¹޾�
�ش��ϴ� ���ǿ� �´� ȸ����� �̾��ش�    */
/
/* �䱸���� 02 */
/*    ������� ����Ž���� ���� ���ϴ� ������ ȸ���� ��ȸ
����) �����̸� ����� �ְ�, ���� ������, ���� �̻��� ȸ���� ��ȸ    */
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
    AND m.gender       ='&����'
    AND m.exp         >= '&��³��'
    AND m.lang LIKE '%&���ɿܱ���%'
    AND m.edu_code >= (select code from edu where name = '&�з�')
    ORDER BY e.code;

BEGIN
  DBMS_OUTPUT.PUT_LINE('�̸�     ����     ���(��)          �ܱ���    �з�');
  DBMS_OUTPUT.PUT_LINE('===============================================');
  OPEN member_cursor;
  LOOP
    FETCH member_cursor INTO mname, mgender, mposition, mexp, mlang, meduname;
    EXIT
  WHEN member_cursor%notfound;
    DBMS_OUTPUT.PUT_LINE(mname||'    '||mgender||'      '||mposition||'  '||mexp||'��'||'       '||mlang||'     '||meduname);
  END LOOP;
  CLOSE member_cursor;
END;
/

-----------------------------------------------------------------------------------������
/* �䱸���� 03 */
/*    ȭ�鿡�� ���ϴ� �ʺ��� �Է¹޾� �� �̻��� ä�����  ��ȸ   */
SELECT C.NAME ȸ���̸�, P.NAME �����о�, J.EXP||'��' �䱸���,
  (SELECT NAME FROM EDU WHERE CODE = J.EDU_CODE) �䱸�з�, J.SAL �ʺ�
FROM JOB J, CMP C, POSITION P
WHERE J.CMP_CODE = C.CODE
AND J.POSITION_CODE = P.CODE
AND J.SAL       >= '&����ʺ�'
ORDER BY J.SAL;

/* �䱸���� 04 */
/*    ȸ���� ������ ���ɺ� �������� Ȯ���ϰ� ���ɺ� �հ� ��踦 ��ȸ
decode�� ��� substr�� �ּ��� ������ �̾Ƽ� ������ ��ü�հ谡 �߰� ������ �ش��ϴ� ������ ���� ���´�
from ���� inline������ ���� ��¥�� �Էµ� ������ ���� months_between���� ����ؼ� 12�� ������ ���̰� ������ age�� alias�� �����ؼ�
case������ �� �� �ְ� �������
case���� �̿��ؼ� �� �� ���ǿ� ������ count�� �ؼ� ����� ���     */
SELECT DECODE(SUBSTR(addr,1,2),NULL,'��ü�հ�',SUBSTR(addr,1,2)) ����,
  COUNT( CASE WHEN age < 20 THEN 1 END) "10��",
  COUNT(CASE WHEN age BETWEEN 20 AND 29 THEN 1 END ) "20��",
  COUNT(CASE WHEN age BETWEEN 30 AND 39 THEN 1 END ) "30��",
  COUNT( CASE WHEN age >= 40 THEN 1 END) "40�� �̻�"
FROM
  (SELECT DISTINCT TRUNC(months_between(SYSDATE, birthday)/12) age ,
    addr
  FROM member)
GROUP BY ROLLUP(SUBSTR(addr,1,2));
select * from member;
/* �䱸���� 05 */
/*    ȭ�鿡�� ������ �̸��� �Է¹޾�, �ش� ȸ���� ������ ä����� ��� ��ȸ(�����ڿ�)   */
SELECT DISTINCT m.name �̸�, c.name ȸ���, 
  (select name from position where code = J.POSITION_code) �����о�, 
  (select name from cmp_size where code = C.cmp_size_code) AS �Ը�, j.sal �ʺ�, c.emp_cnt �����, '��'||NVL(c.tel,'-') ȸ�翬��ó,
  c.addr ȸ���ּ�,(SELECT COUNT(*) FROM APPLY WHERE JOB_CODE = J.CODE) �����ڼ�
FROM member m, apply a, job j, cmp c
WHERE A.member_code = m.code
AND j.cmp_code      = c.code
AND j.code          = A.job_code
AND m.NAME          = '&�̸�'
ORDER BY j.sal DESC ;
SELECT J.CODE,
  ( SELECT COUNT(*) FROM APPLY WHERE JOB_CODE = J.CODE) �����ڼ�
FROM JOB J;

/* �䱸���� 06 */
/*    ��� ������ 3.7�� �̻��� ��� ��ȸ   */
SELECT name AS "����̸�", AVG(cr.rating_sal) "����", AVG(cr.WORK_LIFE) "�����", AVG(cr.RATING_CULTURE) "ȸ�繮ȭ",
  AVG(cr.RATING_PROMO) "������ȸ", AVG(cr.RATING_CEO) "�濵��", '�� '||c.avg_review AS "�������"
FROM cmp c, cmp_review cr
WHERE cr.cmp_code = c.code
AND c.avg_review  > 3.7
GROUP BY name, c.avg_review;

/* �䱸���� 07 */
/*    ����� �Խ��� ä������� ������ ��� ��ȸ�ϱ�(����� �κ� �Է� ����) (�����)
ȭ�鿡�� ������� �Է¹޾ƾ� ��(Ű���� �Է�)     */
SELECT c.name �����,
  (select name from position where code = j.position_code) �����κ�,
  m.name �����ڸ�,
  TRUNC(months_between(SYSDATE, m.birthday)/12)||'��' AS "����",
  (SELECT name FROM edu WHERE code = m.EDU_CODE) AS �з�,
  (select name from position where code = m.exp_position)
  ||DECODE(m.exp,0,'��� ����',' '||m.exp||'��') �����ڰ��,
  NVL(m.lang,'X') ���ɿܱ���, SUBSTR(m.addr,1,2) ��������, '��'||m.tel ����ó, m.email �̸���
FROM cmp c, member m, apply a, job j
WHERE a.job_code  = j.code
AND a.member_code = m.code
AND j.cmp_code    = c.code
AND c.NAME LIKE '%&ȸ���̸�%' --��� �̸�
ORDER BY m.exp DESC;
;

/* �䱸���� 08 */
/*    �ش� ����� ä�� ���� ���� ��� �оߺ�, ��� ����� ������ ��� ��ȸ (�����)
ȭ�鿡�� ������� �Է¹޾ƾ� ��(Ű���� �Է�)     */
SELECT nvl(m.exp_position,'��¾���') ��ºо�,
  count(CASE WHEN m.exp = 0 THEN 1 END) "��� ����",
  count(CASE WHEN m.exp BETWEEN 1 AND 2 THEN 1 END) "��� 1~2��",
  count(CASE WHEN m.exp BETWEEN 3 AND 5 THEN 1 END) "��� 3~5��",
  count(CASE WHEN m.exp >= 6 THEN 1 END) "��� 6�� �̻�"
FROM
  (SELECT p.name AS exp_position, mb.exp, mb.code
    FROM MEMBER mb LEFT JOIN position p ON mb.exp_position = p.code) m,
  APPLY A, JOB j, cmp c
WHERE m.code   = A.member_code
AND A.job_code = j.code
AND j.cmp_code = c.code
AND c.name LIKE '%&ȸ���̸�%' --��� �̸�
GROUP BY nvl(m.exp_position,'��¾���');
;
/* �䱸���� 09 */
/*    ȸ���� ���� ���, ���� ���� ���/�����ϱ�    */
-- ��Ű�� ����
CREATE OR REPLACE PACKAGE bookmark
AS
  -- ���ν��� 4��(
  PROCEDURE bookmark_cmp_insert( --���� ��� ���
      vmember_code bookmark_cmp.member_code%TYPE,
      vcmp_code bookmark_cmp.cmp_code%TYPE);
  PROCEDURE bookmark_cmp_delete( -- ���� ��� ����
      vmember_code bookmark_cmp.member_code%TYPE,
      vcmp_code bookmark_cmp.cmp_code%TYPE);
      
  PROCEDURE bookmark_job_insert( --���� ���� ���
      vmember_code bookmark_job.member_code%TYPE,
      vjob_code bookmark_job.job_code%TYPE);
  PROCEDURE bookmark_job_delete( --���� ���� ����
      vmember_code bookmark_job.member_code%TYPE,
      vjob_code bookmark_job.job_code%TYPE);
END bookmark;
/
-- ��Ű�� ����
CREATE OR REPLACE PACKAGE BODY bookmark
AS
  -- ȸ����ȣ, �����ȣ�� �Է¹޾� bookmark_cmp ���̺� ���ɱ�� ���� ����, CODE���� +1�� �ڵ� ����
  PROCEDURE bookmark_cmp_insert(
      vmember_code bookmark_cmp.member_code%TYPE ,
      vcmp_code bookmark_cmp.cmp_code%TYPE)
  IS
  BEGIN
    INSERT INTO bookmark_cmp VALUES (vmember_code, vcmp_code);
    IF(SQL%rowcount>0) THEN
      DBMS_OUTPUT.PUT_LINE('���� ������� ��ϵǾ����ϴ�.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('��ġ�ϴ� ������ �����ϴ�.');
    END IF;
  END bookmark_cmp_insert;
-- CODE�� �Է¹޾� �ش�Ǵ� BOOKMARK_CMP �� ����
  PROCEDURE bookmark_cmp_delete
    (
      vmember_code bookmark_cmp.member_code%TYPE ,
      vcmp_code bookmark_cmp.cmp_code%TYPE
    )
  IS
  BEGIN
    DELETE FROM bookmark_cmp WHERE member_code = vmember_code and cmp_code = vcmp_code;
    IF(SQL%rowcount>0) THEN
      DBMS_OUTPUT.PUT_LINE('���� �Ǿ����ϴ�.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('��ġ�ϴ� ������ �����ϴ�.');
    END IF;
  END bookmark_cmp_delete;
-- MEMBER_CODE, JOB_CODE�� �Է¹޾� �μ�Ʈ, CODE���� +1�� �ڵ� ����
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
-- CODE�� �Է¹޾� �ش�Ǵ� BOOKMARK_JOB �� ����
  PROCEDURE bookmark_job_delete
    (
      vmember_code bookmark_job.member_code%TYPE,
      vjob_code bookmark_job.job_code%TYPE
    )
  IS
  BEGIN
    DELETE FROM bookmark_job WHERE member_code = vmember_code AND job_code = vjob_code;
    IF (SQL%rowcount>0) THEN
      DBMS_OUTPUT.PUT_LINE('���� �Ǿ����ϴ�.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('��ġ�ϴ� ������ �����ϴ�.');
    END IF;
  END bookmark_job_delete;
END bookmark;
/
-- ��� ����(�巡���ؼ� ����) --
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
/* �䱸���� 10 */
/*    ȸ���� ����� ���� ���� �Է� ��, CMP�� AVG_REVIEW �÷��� ��ü ��� ���� �ݿ�    */
/*    �͸� ������ ���� ȸ�� ������ �Էµ��� �ʾƾ���     */
CREATE OR REPLACE TRIGGER t_cmp_review AFTER
  INSERT ON cmp_review FOR EACH ROW BEGIN
  UPDATE cmp
  SET avg_review = nvl2(avg_review, (avg_review + ((:NEW.rating_sal + :NEW.work_life + :NEW.rating_culture + :NEW.rating_promo + :NEW.rating_ceo) / 5))/2 --
    , NVL(avg_review,0)                         + ( :NEW.rating_sal + :NEW.work_life + :NEW.rating_culture + :NEW.rating_promo + :NEW.rating_ceo) / 5)
  WHERE code = :NEW.cmp_code;
  DBMS_OUTPUT.PUT_LINE('CMP�� ������ �ݿ��Ǿ����ϴ�.');
END ;
/
SELECT * FROM cmp WHERE name = '�������۴�';
INSERT INTO cmp_review VALUES ((SELECT NVL(MAX(code),0)+1 FROM cmp_review),12,5,5,5,5,5);


--AVG�� NULL�� ���
INSERT INTO cmp_review VALUES ((SELECT NVL(MAX(code),0)+1 FROM cmp_review),20,0,0,0,0,0);
SELECT code, NAME, avg_review FROM cmp WHERE code = 20;
INSERT INTO cmp_review VALUES ((SELECT NVL(MAX(code),0)+1 FROM cmp_review),1,1,1,1,1,1);
SELECT code, NAME, avg_review FROM cmp WHERE code = 1;
/
/* ���ο� ���� ��� �˸� */
/*   ȸ���� ����� ���ɱ������ ���ο� ���� �ö����, �ش� ȸ������ ���� �˸��޽��� ����    */
/*   ����) (��)OOO���� ���ο� ���� �ö�Խ��ϴ�.     */
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
        vnotice.member_code, vnotice.NAME||'���� ���ο� ���� �ö�Խ��ϴ�.');
        DBMS_OUTPUT.PUT_LINE('NOTICE�� ���ο� �˸��� �߰� �Ǿ����ϴ�.');
      END LOOP;
    END IF;
  END;
  /
  select * from job;
  SELECT * FROM notice;
  SELECT * FROM bookmark_cmp;
  -- ���ο� ���� ��� (CMP_NO = 12 (�������۴�))
  INSERT INTO job VALUES ((SELECT NVL(MAX(code),0)+1 FROM job),12
  ,(select code from position where name = '������'),3,1,3300);
  SELECT * FROM notice;