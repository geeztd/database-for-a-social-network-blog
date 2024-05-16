CREATE OR REPLACE TRIGGER notify_subscribers
AFTER INSERT ON post
FOR EACH ROW
DECLARE
  v_blog_id NUMBER;
  v_message NVARCHAR2(200);
BEGIN
  v_blog_id := :NEW.blog_id;
  v_message := 'Новый пост опубликован в блоге, на который вы подписаны!';

  FOR sub IN (
    SELECT SUBSCRIBER_ID
    FROM subscription 
    WHERE blog_id = v_blog_id
  ) LOOP
    send_message(sub.subscriber_Id, v_message);
  END LOOP;
END;

CREATE OR REPLACE PROCEDURE send_message(
  user_id IN NUMBER,
  v_message IN NVARCHAR2
) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE(v_message);
END;

CREATE OR REPLACE TRIGGER notify_empty_comment 
BEFORE INSERT ON COMMENT_TABLE
FOR EACH ROW
DECLARE
    trimmed_clob CLOB;
BEGIN
    trimmed_clob := TRIM(:new.Containing);
    IF trimmed_clob IS NULL OR trimmed_clob = '' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Поле не может быть пустым.');
    END IF;
END;

CREATE OR REPLACE TRIGGER notify_empty_post 
BEFORE INSERT ON POST
FOR EACH ROW
DECLARE
    trimmed_clob CLOB;
BEGIN
    trimmed_clob := TRIM(:new.Containing);
    IF trimmed_clob IS NULL OR trimmed_clob = '' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Поле не может быть пустым.');
    END IF;
END;


CREATE OR REPLACE TRIGGER notify_update_time_post
BEFORE UPDATE ON POST
FOR EACH ROW
BEGIN
    :new.Timestamp := SYSTIMESTAMP;
END;

CREATE OR REPLACE TRIGGER notify_update_time_comment
BEFORE UPDATE ON COMMENT_TABLE
FOR EACH ROW
BEGIN
    :new.Timestamp := SYSTIMESTAMP;
END;

