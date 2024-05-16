CREATE OR REPLACE PROCEDURE UpdSubscription (
  SubscriberId IN NUMBER,
  BlogId IN NUMBER,
  res OUT NUMBER 
) 
AS
BEGIN
  INSERT INTO SUBSCRIPTION(subscriber_id, blog_id) VALUES(SubscriberId, BlogId);
  DBMS_OUTPUT.PUT_LINE('Пользователь подписался.');
  COMMIT;
  res:= 1;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN BEGIN
    DELETE FROM SUBSCRIPTION
    WHERE subscriber_id = SubscriberId
      AND blog_id = BlogId;
    COMMIT;
  DBMS_OUTPUT.PUT_LINE('Пользователь отписался.');
  res:= 0;
  END;
  When OTHERS Then BEGIN
  DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
  res:=-1;
  END;
END UpdSubscription;

CREATE OR REPLACE PROCEDURE UpdFavorite (
  UserId IN NUMBER,
  PostId IN NUMBER,
  res OUT NUMBER
) 
AS
BEGIN
  INSERT INTO Favorite(user_id, post_id) VALUES(UserId, PostId);
  DBMS_OUTPUT.PUT_LINE('Пост добавлен в избранное.');
  COMMIT;
  res:=1;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    DELETE FROM Favorite
    WHERE user_id = UserId
      AND post_id = PostId;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Пост удален из избранного.');
    res:=0;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка' || SQLERRM);
    res:=-1;
END UpdFavorite;

CREATE OR REPLACE PROCEDURE UpdLike (
  p_user_id IN NUMBER,
  p_comment_id IN NUMBER,
  res OUT NUMBER
) 
AS
BEGIN
  INSERT INTO Like_Table(user_id, comment_id) VALUES(p_user_id, p_comment_id);
  DBMS_OUTPUT.PUT_LINE('Лайк добавлен');
  COMMIT;
  res:=1;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    DELETE FROM Like_Table
    WHERE user_id = p_user_id
      AND comment_id = p_comment_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Лайк удален');
    res:=0;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка' || SQLERRM);
    res:=-1;
END UpdLike;

CREATE OR REPLACE FUNCTION GETCOUNTSUBFORBLOG(
  p_blog_id IN NUMBER
) RETURN INTEGER AS l_count_sub INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_count_sub FROM
  SUBSCRIPTION s WHERE s.BLOG_ID = p_blog_id;
  return l_count_sub;
END;

CREATE OR REPLACE FUNCTION GETCOUNTSUBFORUSER(
  p_user_id IN NUMBER
) RETURN INTEGER AS l_count_sub INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_count_sub FROM
  SUBSCRIPTION s WHERE s.SUBSCRIBER_ID = p_user_id;
  return l_count_sub;
END;

CREATE OR REPLACE FUNCTION GETCOUNTLIKE(
  p_com_id IN NUMBER
) RETURN INTEGER AS l_count_like INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_count_like FROM
  LIKE_TABLE l WHERE l.COMMENT_ID = p_com_id;
  return l_count_like;
END;

CREATE OR REPLACE FUNCTION GETCOUNTFAVFORUSER(
  p_user_id IN NUMBER
) RETURN INTEGER AS l_count_fav INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_count_fav FROM
  FAVORITE f WHERE f.USER_ID = p_user_id;
  return l_count_fav;
END;

CREATE OR REPLACE FUNCTION GETCOUNTFAVFORPOST(
  p_post_id IN NUMBER
) RETURN INTEGER AS l_count_fav INTEGER;
BEGIN
  SELECT COUNT(*) INTO l_count_fav FROM
  FAVORITE f WHERE f.POST_ID = p_post_id;
  return l_count_fav;
END;

CREATE OR REPLACE FUNCTION SEARCH(p_text IN NVARCHAR2) RETURN SYS_REFCURSOR AS
  l_cursor SYS_REFCURSOR;
BEGIN
  OPEN l_cursor FOR
    SELECT p.*,
           SCORE(1) AS score_containing
    FROM Post p
    WHERE CONTAINS(p.CONTAINING,'$' || p_text, 1) > 0
    ORDER BY score_containing DESC;

  RETURN l_cursor;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    RETURN NULL;
END;

CREATE OR REPLACE FUNCTION import_json_roles (
  p_json_data CLOB
) RETURN VARCHAR2
IS
  l_message VARCHAR2(4000);
BEGIN
  FOR rec IN (
    SELECT *
    FROM JSON_TABLE(
      p_json_data,
      '$[*]'
      COLUMNS (
        name NVARCHAR2(50) PATH '$.Name'
      )
    )
  ) LOOP
    INSERT INTO Role_Table (Name) VALUES (rec.name);
  END LOOP;
  COMMIT;
  l_message := 'Данные JSON успешно импортированы.';
  DBMS_OUTPUT.PUT_LINE(l_message);
  RETURN l_message;
EXCEPTION
  WHEN OTHERS THEN
    l_message := 'Ошибка при импорте JSON: ' || SQLERRM;
    DBMS_OUTPUT.PUT_LINE(l_message);
    RETURN l_message;
END;

CREATE OR REPLACE FUNCTION export_json_roles RETURN CLOB
IS
  l_json_data CLOB;
BEGIN
  SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
      'roleId' VALUE role_id,
      'name'   VALUE Name
    )
  )
  INTO l_json_data
  FROM Role_Table;

  DBMS_OUTPUT.PUT_LINE('Данные экспортированы в JSON.');
  RETURN l_json_data;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка при экспорте JSON: ' || SQLERRM);
    RETURN NULL;
END;
