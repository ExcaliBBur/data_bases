CREATE INDEX lot_time_information_time_finish_idx ON lot_time_information (“time_finish”);
CREATE INDEX item_name_idx ON item (“name”) USING HASH;