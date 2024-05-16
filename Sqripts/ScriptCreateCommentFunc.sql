CREATE OR REPLACE PROCEDURE AddComment (
  p_post_id IN NUMBER,
  p_user_id IN NUMBER,
  p_containing IN VARCHAR2,
  p_comment_id OUT NUMBER
) AS
BEGIN
  INSERT INTO Comment_Table (comment_id, post_id, user_id, containing)
  VALUES (comment_seq.NEXTVAL, p_post_id, p_user_id, p_containing)
  RETURNING comment_id INTO p_comment_id;
  DBMS_OUTPUT.PUT_LINE('Коментарий добавлен');

  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    p_comment_id:=-1;
END;


CREATE OR REPLACE PROCEDURE UpdComment (
  p_comment_id IN NUMBER,
  p_containing IN VARCHAR2 DEFAULT NULL,
  l_updated_count OUT NUMBER
) AS
BEGIN
  UPDATE Comment_Table
  SET containing = NVL(p_containing, containing)
  WHERE comment_id = p_comment_id;
  
  l_updated_count := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('Коментарий обновлен');
  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    l_updated_count:=-1;
END;


CREATE OR REPLACE PROCEDURE DelComment ( 
  p_comment_id IN NUMBER,
  l_deleted_count OUT NUMBER
) AS
BEGIN
  DELETE FROM Comment_Table
  WHERE comment_id = p_comment_id;
  l_deleted_count := SQL%ROWCOUNT; 
  DBMS_OUTPUT.PUT_LINE('Коментарий удален');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Коментарий не найден');
    l_deleted_count:=-1;
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    l_deleted_count:=-1;
END;

CREATE OR REPLACE FUNCTION GetCommentById (
  p_comment_id IN NUMBER
) RETURN Comment_Table%ROWTYPE AS
  l_comment Comment_Table%ROWTYPE;
BEGIN
  SELECT * INTO l_comment
  FROM Comment_Table
  WHERE comment_id = p_comment_id;
  
  RETURN l_comment;
    EXCEPTION
  WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE('Коментарий не найден');
  RETURN NULL;
  WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
  RETURN NULL;
END; 

CREATE OR REPLACE FUNCTION GetCommentsForPost(
    p_post_id IN NUMBER,
    p_start_row IN NUMBER,
    p_count_row IN NUMBER
) RETURN SYS_REFCURSOR AS
    l_cursor SYS_REFCURSOR;
BEGIN
    OPEN l_cursor FOR
        SELECT * FROM (
            SELECT
                com.*,
                GETCOUNTLIKE(com.COMMENT_ID) AS like_count, 
                ROW_NUMBER() OVER (ORDER BY GETCOUNTLIKE(com.COMMENT_ID) DESC) as rn
            FROM COMMENT_TABLE com
            WHERE com.POST_ID = p_post_id
        )
        WHERE rn BETWEEN p_start_row AND (p_start_row + p_count_row);

    return l_cursor;
END;
