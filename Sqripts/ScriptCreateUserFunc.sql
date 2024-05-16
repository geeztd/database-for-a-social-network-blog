CREATE OR REPLACE FUNCTION hash_password (
    p_password IN NVARCHAR2
) RETURN NVARCHAR2
AS
    p_hash_raw RAW(32);
    p_hash_hex NVARCHAR2(255);
BEGIN
    p_hash_raw := DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p_password, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256);
    p_hash_hex := UTL_ENCODE.base64_encode(p_hash_raw);
    RETURN p_hash_hex;
END;

CREATE OR REPLACE PROCEDURE AddUser (
  login IN VARCHAR2,
  password IN VARCHAR2,
  email IN VARCHAR2,
  name IN VARCHAR2,
  secondname IN VARCHAR2,
  age IN NUMBER,
  RoleId IN NUMBER,
  UserId OUT number
) 
AS
BEGIN
  INSERT INTO User_Table(login, password, email, name, secondname, age, role_id)
   VALUES(AddUser.login,  hash_password(AddUser.password), AddUser.email, AddUser.name, AddUser.secondname, AddUser.age, AddUser.RoleId);
  DBMS_OUTPUT.PUT_LINE('Пользователь добавлен');
  COMMIT;
  select user_id into UserId from user_table where login = AddUser.login;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN BEGIN
      IF SQLERRM LIKE '%unique_login%' THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Пользователь с таким логином уже существует.');
        UserId:=-1;
      ELSIF SQLERRM LIKE '%unique_email%' THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Пользователь с таким email уже существует.');
        UserId:= -2;
      ELSE
        RAISE;
      END IF;
    END;
  WHEN OTHERS THEN BEGIN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    UserId:= -3;
    END;
END AddUser;

CREATE OR REPLACE FUNCTION GetUserById (
  p_user_id IN NUMBER
) RETURN User_Table%ROWTYPE AS
  l_user User_Table%ROWTYPE;
BEGIN
  SELECT * INTO l_user
  FROM User_Table
  WHERE user_id = p_user_id;
  
  RETURN l_user;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Пользователь с ID: ' || p_user_id || ' не найден.');
    RETURN NULL;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    RETURN NULL;
END GetUserById;

CREATE OR REPLACE FUNCTION GetUserByLogin (
  p_login IN VARCHAR2
) RETURN User_Table%ROWTYPE AS
  l_user User_Table%ROWTYPE;
BEGIN
  SELECT * INTO l_user
  FROM User_Table
  WHERE login = p_login;
  
  RETURN l_user;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Пользователь с логином: ' || p_login || ' не найден.');
    RETURN NULL;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    RETURN NULL;
END GetUserByLogin;

CREATE OR REPLACE FUNCTION GetUserByEmail (
  p_email IN VARCHAR2
) RETURN User_Table%ROWTYPE AS
  l_user User_Table%ROWTYPE;
BEGIN
  SELECT * INTO l_user
  FROM User_Table
  WHERE email = p_email;
  
  RETURN l_user;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Пользователь с email: ' || p_email || ' не найден.');
    RETURN NULL;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    RETURN NULL;
END GetUserByEmail;

CREATE OR REPLACE PROCEDURE DelUserById (
  p_user_id IN NUMBER,
  l_deleted_count OUT NUMBER
) AS
BEGIN
  DELETE FROM User_Table
  WHERE user_id = p_user_id;
  
  l_deleted_count := SQL%ROWCOUNT;
  
  IF l_deleted_count > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Пользователь с ID: ' || p_user_id || ' удален.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Пользователь с ID: ' || p_user_id || ' не найден.');
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    l_deleted_count:= -1;
END DelUserById;

CREATE OR REPLACE PROCEDURE UpdUserById (
  p_user_id IN NUMBER,
  p_password IN VARCHAR2 DEFAULT NULL,
  p_email IN VARCHAR2 DEFAULT NULL,
  p_name IN VARCHAR2 DEFAULT NULL,
  p_secondname IN VARCHAR2 DEFAULT NULL,
  p_age IN NUMBER DEFAULT NULL,
  p_role_id IN NUMBER DEFAULT NULL,
  l_updated_count OUT NUMBER
) AS
  p_hash_password NVARCHAR2(255);
BEGIN
  IF p_password IS NOT NULL THEN
     p_hash_password := hash_password(p_password);
  ELSE p_hash_password := NULL;
  END IF;
  UPDATE User_Table
  SET password = NVL(p_hash_password, password),
      email = NVL(p_email, email),
      name = NVL(p_name, name),
      secondname = NVL(p_secondname, secondname),
      age = NVL(p_age, age),
      role_id = NVL(p_role_id, role_id)
  WHERE user_id = p_user_id;
  
  l_updated_count := SQL%ROWCOUNT;
  
  IF l_updated_count > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Пользователь с ID: ' || p_user_id || ' обновлен.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Пользователь с ID: ' || p_user_id || ' не найден.');
  END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
      DBMS_OUTPUT.PUT_LINE('Ошибка: Пользователь с таким email уже существует.');
      l_updated_count := -1;
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    l_updated_count := -1;
END UpdUserById;
