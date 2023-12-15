CREATE FUNCTION set_end_time() RETURNS trigger AS $$
BEGIN
  IF NEW.status = 'EXPIRED'
  THEN UPDATE lot_time_information SET time_finish = time_end WHERE lot_time_information.lot_id = NEW.lot_id;
  ELSEIF NEW.status = 'SOLD'
  THEN UPDATE lot_time_information SET time_finish = CURRENT_TIMESTAMP WHERE lot_time_information.lot_id = NEW.lot_id;
  END IF;
  RETURN NEW;
END
$$ LANGUAGE plpgsql;   

CREATE TRIGGER set_endtime
BEFORE UPDATE ON lot_status_information
FOR EACH ROW EXECUTE PROCEDURE set_end_time();

CREATE FUNCTION set_registration_date() RETURNS trigger AS $$
BEGIN
  NEW.registration_date := NOW()::date;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_registration_date
BEFORE INSERT ON _user
FOR EACH ROW EXECUTE PROCEDURE set_registration_date();

CREATE FUNCTION set_time_start() RETURNS trigger AS $$
BEGIN
  NEW.time_start := NOW()::date;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_time_start
BEFORE INSERT ON lot_time_information
FOR EACH ROW EXECUTE PROCEDURE set_time_start();

CREATE FUNCTION create_lot_status_information() RETURNS trigger AS $$
BEGIN
  INSERT INTO lot_status_information(status) VALUES ('ACTIVE');
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_lot_status_information
AFTER INSERT ON lot
FOR EACH ROW EXECUTE PROCEDURE create_lot_status_information();

CREATE FUNCTION create_lot_time_information() RETURNS trigger AS $$
BEGIN
  INSERT INTO lot_time_information(time_start) VALUES (CURRENT_TIMESTAMP);
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_lot_time_information
AFTER INSERT ON lot
FOR EACH ROW EXECUTE PROCEDURE create_lot_time_information();

CREATE FUNCTION fill_start_price() RETURNS trigger AS $$
BEGIN
  UPDATE lot_cost_information SET cost_current = cost_start WHERE lot_cost_information.lot_id = NEW.lot_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fill_start_price
AFTER INSERT ON lot_cost_information
FOR EACH ROW EXECUTE PROCEDURE fill_start_price();