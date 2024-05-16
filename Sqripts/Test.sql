INSERT INTO USER_TABLE(login,PASSWORD,EMAIL,name,SECONDNAME,AGE,ROLE_ID) VALUES(
    'Пользователь','12345qwerty','adaw@gmail.com','Marat','petrov',19,3
);
INSERT INTO BLOG(USER_ID,NAME,DISCRIPTION) VALUES(1,'BLOG1','blog1blog1');

INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','Сегодняшний день начался с яркого солнца и прохладного ветра.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','В парке зацвели первые весенние цветы, наполнившие воздух ароматом.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','Вечером планирую прогуляться по набережной и насладиться закатом.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','На кухне раскатывается аромат свежей выпечки, готовится ужин для семьи.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','После дождя в саду открылись новые почки на розовых кустах.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','The sun is shining brightly, casting long shadows on the ground.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','Spring has arrived, and flowers are blooming in every corner of the garden.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','Tonight, I`m planning to have dinner with friends at a cozy restaurant downtown.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','The sound of laughter fills the air as children play in the park.');
INSERT INTO POST(BLOG_ID,NAME,CONTAINING) VALUES(1,'post1','I`m looking forward to a relaxing weekend, spent reading books and enjoying nature.');

SELECT * from COMMENT_TABLE;
DECLARE
  v_containing CLOB := 'Пример комментария.';
BEGIN
FOR i in 21..30 LOOP
  FOR j IN 1..10000 LOOP
    INSERT INTO Comment_Table (User_Id, Post_Id, Containing)
    VALUES (1, i, v_containing || j);
  END LOOP;
END LOOP;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('100000 комментариев добавлено.');
END;

SELECT * from COMMENT_TABLE com where
com.COMMENT_ID < 100 or com.COMMENT_ID > 90000;
