/*
 Versioning for the database. The application looks in this table to determine
 whether to update the database.

 version -- Increasing versions number.
 date    -- When the new database version was created.
 */
CREATE TABLE IF NOT EXISTS db_version
(
    version INTEGER PRIMARY KEY,
    date    TEXT    NOT NULL
);

/*
 Accounts in which assets are stored.

 bank     -- Where the account is; doesn't have to be a bank, it can be some
             other institution.
 comments -- Comments; can be the type of account or whether it's shared with
             someone else.
 */
CREATE TABLE IF NOT EXISTS account
(
    id       INTEGER PRIMARY KEY,
    name     TEXT    NOT NULL,
    bank     TEXT    DEFAULT NULL,
    comments TEXT    DEFAULT NULL
);

/*
 Types of assets, for example stocks, bonds, funds and crypto currencies.
 */
CREATE TABLE IF NOT EXISTS asset_type
(
    id   INTEGER PRIMARY KEY,
    name TEXT    NOT NULL
);

/*
 Individual assets, for example stocks, bonds, funds and crypto currencies.

 exists_in_hk -- Boolean. Whether the asset exists in the software "Hitta
                 Kursvinnare".
 */
CREATE TABLE IF NOT EXISTS asset
(
    id           INTEGER PRIMARY KEY,
    name         TEXT    NOT NULL,
    type         INTEGER NOT NULL,
    exists_in_hk INTEGER DEFAULT 0,

    FOREIGN KEY (type) REFERENCES asset_type(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

/*
 The mode of recurrent savings of an asset, for example "Automatic", "Manual"
 and "None".
 */
CREATE TABLE IF NOT EXISTS recurrent_savings
(
    id   INTEGER PRIMARY KEY,
    mode TEXT    NOT NULL
);

/*
 Connects assets with accounts. Each asset may be in multiple accounts and each
 account can obviously contain multiple assets.

 currently_own -- Boolean. Whether the user currently has the asset on the
                  account. For an asset to be in this table, it doesn't have to
                  be in the account *right now*, just that it normally should
                  be here.
 should_keep   -- Boolean. Whether the asset should remain on the account even
                  when it's not currently owned.
 */
CREATE TABLE IF NOT EXISTS asset_in_account
(
    asset             INTEGER NOT NULL,
    account           INTEGER NOT NULL,
    currently_own     INTEGER DEFAULT 1,
    should_keep       INTEGER DEFAULT 1,
    recurrent_savings INTEGER NOT NULL,

    PRIMARY KEY (asset, account),

    FOREIGN KEY (asset)             REFERENCES asset(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (account)           REFERENCES account(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (recurrent_savings) REFERENCES recurrent_savings(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS recommendation
(
    id   INTEGER PRIMARY KEY,
    name TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS analysis
(
    date             TEXT    NOT NULL,
    asset_in_account INTEGER NOT NULL,
    recommendation   INTEGER NOT NULL,

    PRIMARY KEY (date, asset_in_account),

    FOREIGN KEY (asset_in_account) REFERENCES asset_in_account(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (recommendation)   REFERENCES recommendation(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_analysis_recommendation
    ON analysis(recommendation);

CREATE TABLE IF NOT EXISTS indicator
(
    id   INTEGER PRIMARY KEY,
    name TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS signal
(
    date             TEXT    NOT NULL,
    asset_in_account INTEGER NOT NULL,
    indicator        INTEGER NOT NULL,
    buy_or_sell      INTEGER NOT NULL,

    PRIMARY KEY (date, asset_in_account, indicator),

    FOREIGN KEY (asset_in_account) REFERENCES asset_in_account(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (indicator)        REFERENCES indicator(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_db_version_date ON db_version(date);
CREATE INDEX IF NOT EXISTS idx_asset_name ON asset(name);
CREATE INDEX IF NOT EXISTS idx_asset_in_account_recurrent_savings
    ON asset_in_account(recurrent_savings);

INSERT INTO db_version (version, date) VALUES (1, '2020-11-24');
