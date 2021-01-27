class WorldParser {
  
  EnvironmentParser ep;
  SeedParser sp;

  WorldParser() {
    ep = new EnvironmentParser();
    sp = new SeedParser();
  }

}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

class EnvironmentParser {
  
  String ethEnvUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTqp3uM7s0sq75YKWPfLx76bmZpp5z6df-iiMlM-n3GDsIqKhbyjqgu0L4gPWR3I3E2HfVRU8ERZ0Mr/pub?gid=0&single=true&output=csv"; //"https://digiconomist.net/ethereum-energy-consumption";
  Table ethTable;

  String btcEnvUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTRyoqMKaNKl0KD2TIyRshcHv00gPjkXF5BaEW6ADVFH1ikTwwZkxDLmbdAxCFHvjdJxHv_t40U7R7s/pub?gid=0&single=true&output=csv"; //"https://digiconomist.net/bitcoin-energy-consumption";
  Table btcTable;
  
  EnvironmentParser() {
    ethTable = loadTable(ethEnvUrl, "csv, header");
    for (TableRow row : ethTable.rows()) {
      String date = row.getString("Date");
      float estTWh = row.getFloat("Estimated TWh per Year");
      if (Float.isNaN(estTWh)) estTWh = 0;
      float minTWh = row.getFloat("Minimum TWh per Year");
      if (Float.isNaN(minTWh)) minTWh = 0;
    }

    btcTable = loadTable(btcEnvUrl, "csv, header");
    for (TableRow row :btcTable.rows()) {
      String date = row.getString("Date");
      float estTWh = row.getFloat("Estimated TWh per Year");
      if (Float.isNaN(estTWh)) estTWh = 0;
      float minTWh = row.getFloat("Minimum TWh per Year");
      if (Float.isNaN(minTWh)) minTWh = 0;
    }
  }
  
  /* Notes:
  Date, Estimated TWh per Year, Minimum TWh per Year
  */
    
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

class SeedParser {
  
  String ethSeedUrl = "https://api.blockcypher.com/v1/eth/main";
  JSONObject ethJson;

  String btcSeedUrl = "https://api.blockcypher.com/v1/btc/main";
  JSONObject btcJson;
  
  int eth_peer_count, btc_peer_count;
  
  SeedParser() {
    ethJson = loadJSONObject(btcSeedUrl);
    btcJson = loadJSONObject(ethSeedUrl);

    eth_peer_count = ethJson.getInt("peer_count");
    btc_peer_count = btcJson.getInt("peer_count");
  }
  
}

/* Notes:
{
  "name": "ETH.main",
  "height": 11734007,
  "hash": "a784e7b909a6627d0c7d9562e0230a03a2a007ba618683ceb192dfe2f454175b",
  "time": "2021-01-26T22:15:10.211009373Z",
  "latest_url": "https://api.blockcypher.com/v1/eth/main/blocks/a784e7b909a6627d0c7d9562e0230a03a2a007ba618683ceb192dfe2f454175b",
  "previous_hash": "00f7609be87288a1cbedc8a36ab331098266753a4b789190fb5f1a0108cd7b9e",
  "previous_url": "https://api.blockcypher.com/v1/eth/main/blocks/00f7609be87288a1cbedc8a36ab331098266753a4b789190fb5f1a0108cd7b9e",
  "peer_count": 78,
  "unconfirmed_count": 135391,
  "high_gas_price": 57804148592,
  "medium_gas_price": 19780414859,
  "low_gas_price": 5000000000,
  "last_fork_height": 11733509,
  "last_fork_hash": "b18448f592e1f1c2bb43072eb960f599332712f2dea19cea3195df1e6b610fa4"
}

{
  "name": "BTC.main",
  "height": 667818,
  "hash": "00000000000000000002a6bf8985c198492f83174d00100fe44d73944459481d",
  "time": "2021-01-26T22:12:14.121745917Z",
  "latest_url": "https://api.blockcypher.com/v1/btc/main/blocks/00000000000000000002a6bf8985c198492f83174d00100fe44d73944459481d",
  "previous_hash": "00000000000000000007d2fb8452c83b5814af71f590b47af649d0d58907ca12",
  "previous_url": "https://api.blockcypher.com/v1/btc/main/blocks/00000000000000000007d2fb8452c83b5814af71f590b47af649d0d58907ca12",
  "peer_count": 1045,
  "unconfirmed_count": 25434,
  "high_fee_per_kb": 84898,
  "medium_fee_per_kb": 50784,
  "low_fee_per_kb": 37172,
  "last_fork_height": 662642,
  "last_fork_hash": "0000000000000000000c7af1e0b2172f1eed6b4d0707ea135c267ba263c7acf1"
}
*/
