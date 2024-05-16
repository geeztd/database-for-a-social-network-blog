
CREATE OR REPLACE PROCEDURE AddPost (
  p_blog_id IN NUMBER,
  p_name IN VARCHAR2,
  p_containing IN CLOB,
  p_post_id OUT NUMBER
) AS
BEGIN
  INSERT INTO Post (post_id, blog_id, name, containing)
  VALUES (post_seq.NEXTVAL, p_blog_id, p_name, p_containing)
  RETURNING post_id INTO p_post_id;
  DBMS_OUTPUT.PUT_LINE('Пост добавлен');
  
  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    p_post_id:=-1;
END;

CREATE OR REPLACE PROCEDURE UpdPost (
  p_post_id IN NUMBER,
  p_name IN VARCHAR2 DEFAULT NULL,
  p_containing IN CLOB DEFAULT NULL,
  l_updated_count OUT NUMBER
) AS
BEGIN
  UPDATE Post
  SET name = NVL(p_name, name),
      containing = NVL(p_containing, containing)
  WHERE post_id = p_post_id;

  l_updated_count := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Пост обновлен');
  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    l_updated_count:=-1;
END;

CREATE OR REPLACE PROCEDURE DelPost (
  p_post_id IN NUMBER,
  l_deleted_count OUT NUMBER
) AS
BEGIN
  DELETE FROM Post
  WHERE post_id = p_post_id;

  l_deleted_count := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Пост удален');
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('пост не найден');
    l_deleted_count:=-1;
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    l_deleted_count:=-1;
END;

CREATE OR REPLACE FUNCTION GetPostById (
  p_post_id IN NUMBER
) RETURN Post%ROWTYPE AS
  l_post Post%ROWTYPE;
BEGIN
  SELECT * INTO l_post
  FROM Post
  WHERE post_id = p_post_id;
  
  RETURN l_post;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  DBMS_OUTPUT.PUT_LINE('пост не найден');
  RETURN NULL;
  WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
  RETURN NULL;
END;

CREATE OR REPLACE FUNCTION GetAllPosts RETURN SYS_REFCURSOR AS
  l_cursor SYS_REFCURSOR;
BEGIN
  OPEN l_cursor FOR
    SELECT * 
    FROM Post;
  
  RETURN l_cursor;
END;

CREATE OR REPLACE PROCEDURE ADDVIEWPOST(
  p_post_id IN NUMBER,
  l_updated_count OUT NUMBER
)
 AS 
 BEGIN
  UPDATE POST
  SET CountViews = CountViews + 1 WHERE post_id = p_post_id;
    l_updated_count := SQL%ROWCOUNT;
  END ADDVIEWPOST;

CREATE OR REPLACE FUNCTION GETPOSTFORBLOG(
    p_blog_id IN NUMBER,
    p_start_row IN NUMBER,
    p_count_row IN NUMBER,
    p_sort_column VARCHAR2 DEFAULT 'COUNTVIEWS',
    p_sort_direction VARCHAR2 DEFAULT 'DESC'
) RETURN SYS_REFCURSOR AS
    l_cursor SYS_REFCURSOR;
BEGIN
    OPEN l_cursor FOR
        SELECT * FROM (
            SELECT
                p.*,
                ROW_NUMBER() OVER (ORDER BY 
                    CASE when p_sort_direction = 'ASC' then
                       case WHEN p_sort_column = 'COUNTVIEWS' THEN p.COUNTVIEWS
                            WHEN p_sort_column = 'FAVORITE_COUNT' then favorite_count
                            when p_sort_column = 'CREATION_DATE'THEN (p."TIMESTAMP" - TO_DATE('1970-01-01', 'YYYY-MM-DD')) * 86400
                        end
                      end,
                    CASE when p_sort_direction = 'DESC' then
                       case WHEN p_sort_column = 'COUNTVIEWS' THEN p.COUNTVIEWS
                            WHEN p_sort_column = 'FAVORITE_COUNT' then favorite_count
                            when p_sort_column = 'CREATION_DATE'THEN (p."TIMESTAMP" - TO_DATE('1970-01-01', 'YYYY-MM-DD')) * 86400
                        end
                      end DESC) as rn
            FROM (
                SELECT ps.*, GETCOUNTFAVFORPOST(ps.POST_ID) AS favorite_count
                FROM POST ps
                WHERE BLOG_ID = p_blog_id 
            ) p 
        )
    WHERE rn BETWEEN p_start_row AND (p_start_row + p_count_row);
    return l_cursor;
END;