CREATE TABLE IF NOT EXISTS _user (
  login TEXT PRIMARY KEY,
  birth_date DATE NOT NULL,
  registration_date DATE
);

CREATE TABLE IF NOT EXISTS item (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  properties JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS lot (
  id SERIAL PRIMARY KEY,
  user_login TEXT NOT NULL,
  item_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_login) REFERENCES _user (login)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (item_id) REFERENCES item (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS lot_cost_information (
  lot_id SERIAL PRIMARY KEY,
  cost_start BIGINT NOT NULL,
  cost_current BIGINT,
  cost_buy BIGINT,
  
  FOREIGN KEY (lot_id) REFERENCES lot (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS lot_time_information (
  lot_id SERIAL PRIMARY KEY,
  time_start TIMESTAMP NOT NULL,
  time_end TIMESTAMP,
  time_finish TIMESTAMP,
  
  FOREIGN KEY (lot_id) REFERENCES lot (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS lot_status_information (
  lot_id SERIAL PRIMARY KEY,
  status TEXT NOT NULL,
  
  FOREIGN KEY (lot_id) REFERENCES lot (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS dependency (
  id SERIAL PRIMARY KEY,
  item_first_id INTEGER NOT NULL,
  item_second_id INTEGER NOT NULL,
  
  FOREIGN KEY (item_first_id) REFERENCES item (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (item_second_id) REFERENCES item (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS password (
  user_login TEXT PRIMARY KEY,
  password TEXT NOT NULL,
  
  FOREIGN KEY (user_login) REFERENCES _user (login)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS item_category (
  item_id INTEGER PRIMARY KEY,
  category TEXT NOT NULL,
  
  FOREIGN KEY (item_id) REFERENCES item (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS favourite (
  id SERIAL PRIMARY KEY,
  user_login TEXT NOT NULL,
  item_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_login) REFERENCES _user (login)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (item_id) REFERENCES item (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  UNIQUE (user_login, item_id)
);