/*
 Versioning for the database. The application looks in this table to determine
 whether to update the database.

 version -- Increasing version numbers.
 date    -- When the new database version was created.
 */
CREATE TABLE IF NOT EXISTS db_version
(
    version INTEGER PRIMARY KEY,
    date    TEXT    NOT NULL
);

/*
 Accounts in which assets are stored.

 id       -- Unique ID.
 name     -- The account name or other relevant identifier.
 bank     -- Where the account is; doesn't have to be a bank, it can be some
             other institution.
 comments -- Comments on for example the type of account or whether it's shared
             with someone else.
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

 id    -- Unique ID.
 label -- Description of the asset type.
 */
CREATE TABLE IF NOT EXISTS asset_type
(
    id    INTEGER PRIMARY KEY,
    label TEXT    NOT NULL
);

/*
 Individual assets, for example stocks, bonds, funds and crypto currencies.

 id           -- Unique ID.
 name         -- The asset's name.
 type         -- Asset type.
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

 id   -- Unique ID.
 mode -- Name of the mode.
 */
CREATE TABLE IF NOT EXISTS recurrent_savings
(
    id   INTEGER PRIMARY KEY,
    mode TEXT    NOT NULL
);

/*
 Connects assets with accounts. Each asset may be in multiple accounts and each
 account can obviously contain multiple assets.

 asset             -- An asset.
 account           -- The account in which the asset is.
 currently_own     -- Boolean. Whether the user currently has the asset on the
                      account. For an asset to be in this table, it doesn't
                      have to be in the account *right now*, just that it
                      normally should be here.
 should_keep       -- Boolean. Whether the asset should remain on the account
                      even when it's not currently owned.
 recurrent_savings -- The mode of recurrent savings.
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

/*
 Types of recommendations, for example "Buy", "Sell", "Hold" and "Wait".

 id    -- Unique ID.
 label -- Description of the type of recommendation.
 */
CREATE TABLE IF NOT EXISTS recommendation
(
    id    INTEGER PRIMARY KEY,
    label TEXT    NOT NULL
);

/*
 An analysis of one asset on a particular date. This analysis is the
 amalgamation of all signals used for this particular asset.

 date           -- The date when the analysis was made.
 asset          -- The asset being analysed.
 recommendation -- What recommendation the analysis gives for the particular
                   asset.
 comments       -- Comments on the analysis.
 */
CREATE TABLE IF NOT EXISTS analysis
(
    date           TEXT    NOT NULL,
    asset          INTEGER NOT NULL,
    recommendation INTEGER NOT NULL,
    comments       TEXT    DEFAULT NULL,

    PRIMARY KEY (date, asset),

    FOREIGN KEY (asset)          REFERENCES asset(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (recommendation) REFERENCES recommendation(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

/*
 Technical analysis indicators.

 id          -- Unique ID.
 name        -- Name of the indicator. Should include time scope, for example
                "SMA 7/14 weeks". That way, it's easy to differentiate between
                that and for example "SMA 7/14 days".
 description -- An optional description of the indicator.
 */
CREATE TABLE IF NOT EXISTS indicator
(
    id          INTEGER PRIMARY KEY,
    name        TEXT    NOT NULL,
    description TEXT    DEFAULT NULL
);

/*
 Individual signals on a particular asset using a particular indicator on a
 particular date.

 date        -- The date of the signal.
 asset       -- The asset that gives the signal.
 indicator   -- The indicator on which the signal is based.
 buy_or_sell -- Single integer denoting whether this is a signal to buy (1), a
                signal to sell (-1) or no clear signal (0).
 */
CREATE TABLE IF NOT EXISTS signal
(
    id          INTEGER PRIMARY KEY,
    date        TEXT    NOT NULL,
    asset       INTEGER NOT NULL,
    indicator   INTEGER NOT NULL,
    buy_or_sell INTEGER NOT NULL,

    FOREIGN KEY (asset)     REFERENCES asset(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (indicator) REFERENCES indicator(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

/*
 Weights for each signal. They are used to calculate a recommendation based on
 multiple signals for a single asset.

 date   -- On which date the weighing was conducted.
 signal -- Which signal to weigh.
 weight -- The weight of the signal, based on the weighing on the given date.
 */
CREATE TABLE IF NOT EXISTS signal_weight
(
    date    TEXT    NOT NULL,
    signal  INTEGER NOT NULL,
    weight  REAL    NOT NULL,

    PRIMARY KEY (date, signal),

    FOREIGN KEY (signal) REFERENCES signal(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

/* Indices of columns on which I suspect are going to be searched a lot. */
CREATE INDEX IF NOT EXISTS idx_db_version_date ON db_version(date);
CREATE INDEX IF NOT EXISTS idx_asset_name ON asset(name);
CREATE INDEX IF NOT EXISTS idx_asset_in_account_recurrent_savings
    ON asset_in_account(recurrent_savings);
CREATE INDEX IF NOT EXISTS idx_analysis_recommendation
    ON analysis(recommendation);

/* The contents of this SQL file belong to version 1 of the database. */
INSERT INTO db_version (version, date) VALUES (1, '2020-11-24');
