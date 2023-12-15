CREATE OR REPLACE PROCEDURE create_user(
  IN login TEXT,
  IN birth_date DATE,
  IN registration_date DATE,
  IN password TEXT
) AS $$
BEGIN
  INSERT INTO _user (login, birth_date, registration_date)
  VALUES (login, birth_date, registration_date);

  INSERT INTO password (user_login, password)
  VALUES (login, password);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE create_lot(
  IN user_login TEXT,
  IN item_id INTEGER,
  IN cost_start BIGINT,
  IN cost_buy BIGINT,
  IN _time_end TIMESTAMP
) AS $$
DECLARE _lot_id INTEGER;
BEGIN
  INSERT INTO lot (user_login, item_id) 
  VALUES (user_login, item_id)
  RETURNING lot.id into _lot_id;

  INSERT INTO lot_cost_information (cost_start, cost_buy)
  VALUES (cost_start, cost_buy);

  UPDATE lot_time_information SET time_end = _time_end
  WHERE lot_time_information.lot_id = _lot_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE create_item(
  IN item_id INTEGER,
  IN name TEXT,
  IN properties JSONB,
  IN category TEXT
) AS $$
BEGIN
  INSERT INTO item (id, name, properties) 
  VALUES (item_id, name, properties);

  INSERT INTO item_category (item_id, category)
  VALUES (item_id, category);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_max_cost_buy_per_day_in_month(_start TIMESTAMP, _finish TIMESTAMP, _name TEXT) 
RETURNS table(day DATE, max_cost_buy BIGINT, quantity BIGINT)
AS $$
BEGIN
  RETURN query SELECT date_trunc('day', time_finish)::DATE, MAX(cost_buy) AS max_cost_buy_per_day, COUNT(1)
  FROM lot
  JOIN lot_status_information ON lot.id = lot_status_information.lot_id 
  AND lot_status_information.status = 'SOLD'
  JOIN lot_time_information ON lot.id = lot_time_information.lot_id 
  AND (time_finish BETWEEN _start AND _finish)
  JOIN lot_cost_information ON lot.id = lot_cost_information.lot_id
  JOIN item ON lot.item_id = item.id AND item.name = _name
  GROUP BY 1;
END;
$$ LANGUAGE plpgsql;

select * From get_max_cost_buy_per_day_in_month(timestamp '2023-12-01 00:00:00', timestamp '2024-01-01 00:00:00', 'Worn Shortsword');

CREATE OR REPLACE FUNCTION get_by_category(IN _category TEXT) 
RETURNS table(item_id INTEGER)
AS $$
BEGIN
  RETURN QUERY SELECT item.id 
  FROM item 
  JOIN item_category ON item.id = item_category.item_id 
  WHERE item_category.category = _category;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_active_by_item_name(IN _name TEXT) 
RETURNS table(id INTEGER, user_login TEXT, item_id INTEGER)
AS $$
BEGIN
  RETURN QUERY SELECT lot.* FROM lot 
               JOIN lot_status_information ON lot.id = lot_status_information.lot_id 
               JOIN item ON lot.item_id = item.id
               WHERE item.name = _name AND lot_status_information.status = 'ACTIVE';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_selfprice(IN _item_id INTEGER) 
RETURNS BIGINT
AS $$
DECLARE 
  sum BIGINT;
  temprow INTEGER;
  curr_price BIGINT;
BEGIN
  sum := 0;
  curr_price := (SELECT MIN(cost_current) FROM lot
        JOIN lot_cost_information ON lot.id = lot_cost_information.lot_id
        JOIN lot_status_information ON lot.id = lot_status_information.lot_id AND lot_status_information.status = 'ACTIVE'
        WHERE lot.item_id = _item_id
        GROUP BY item_id);
    IF EXISTS (SELECT dependency.item_second_id from dependency WHERE dependency.item_first_id = _item_id)
  THEN 
    FOR temprow IN 
        (SELECT dependency.item_second_id from dependency WHERE dependency.item_first_id = _item_id)
    LOOP
        sum := sum + calculate_selfprice(temprow);
    END LOOP;
  ELSE
    sum := curr_price;
  END IF;
  IF (sum >= curr_price)
  THEN
    RETURN curr_price;
  ELSE
    RETURN sum;
  END IF;
END;
$$ LANGUAGE plpgsql;