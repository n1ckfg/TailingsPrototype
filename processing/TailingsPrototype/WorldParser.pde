class WorldParser {
  
  EnvironmentParser ep;
  SeedParser sp;
  Target target;
  
  boolean firstRun = true;

  int refreshSeedIntervalOrig = 10000;
  int refreshSeedIntervalTimeout = 100000; // wait longer to try again if the API enforces a timeout
  int refreshSeedInterval = refreshSeedIntervalOrig;
  int lastSeedUpdate = 0;
  int refreshEnvironmentInterval = 24*60*60*1000; // once per day;
  int lastEnvironmentUpdate = 0;

  boolean seedDebug = false;
  float seedDebugOdds = 0.006;
      
  WorldParser() {
    ep = new EnvironmentParser();
    sp = new SeedParser(); 
    target = new Target(width, height);
  }
  
  void update() {
    if (firstRun) {
      updateEp();
      updateSp();
      firstRun = false;
    }
    
    if (millis() > lastEnvironmentUpdate + refreshEnvironmentInterval) {
      updateEp();
    }
    
    if (millis() > lastSeedUpdate + refreshSeedInterval) {
      updateSp();
    }
    
    // if the api call fails, estimate the result
    if (seedDebug && random(1) < seedDebugOdds) sp.changed = true;

    target.update();
  }
  
  void updateEp() {
    ep.update();
    
    target.speed = (ep.ethCurrentEnergy + ep.btcCurrentEnergy) * 0.0002;
    println("Target speed: " + target.speed);
    
    lastEnvironmentUpdate = millis();
  }
  
  void updateSp() {
    try {
      sp.update();  
      refreshSeedInterval = refreshSeedIntervalOrig;
      seedDebug = false;
    } catch (Exception e) { 
      refreshSeedInterval = refreshSeedIntervalTimeout;
      seedDebug = true;
      sp.changed = true;
    }
    
    lastSeedUpdate = millis();
  }
  
  long mapLong(long value, long min1, long max1, long min2, long max2) {
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
  }

  double mapDouble(double value, double min1, double max1, double min2, double max2) {
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
  }
  
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

class EnvironmentParser {
  
  String ethCirculationUrl = "https://api.blockchair.com/ethereum/blocks?a=date,sum(generation)";
  JSONObject ethCirculationJson;
  
  String ethEnergyUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTqp3uM7s0sq75YKWPfLx76bmZpp5z6df-iiMlM-n3GDsIqKhbyjqgu0L4gPWR3I3E2HfVRU8ERZ0Mr/pub?gid=0&single=true&output=csv"; //"https://digiconomist.net/ethereum-energy-consumption";
  Table ethEnergyTable;

  String btcCirculationUrl = "https://api.blockchair.com/bitcoin/blocks?a=date,sum(generation)";
  JSONObject btcCirculationJson;

  String btcEnergyUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTRyoqMKaNKl0KD2TIyRshcHv00gPjkXF5BaEW6ADVFH1ikTwwZkxDLmbdAxCFHvjdJxHv_t40U7R7s/pub?gid=0&single=true&output=csv"; //"https://digiconomist.net/bitcoin-energy-consumption";
  Table btcEnergyTable;
  
  float ethCurrentEnergy, btcCurrentEnergy;
  long ethCurrentCirculation, btcCurrentCirculation;
  
  float[] ethEnergyArray, btcEnergyArray;
  long[] ethCirculationArray, btcCirculationArray;
  
  boolean doCirculation = false;
  boolean getLatestOnly = true;
  
  EnvironmentParser() {
    //
  }
  
  void getCirculation() {
    println("* Downloading ETH circulation data");
    ethCirculationJson = loadJSONObject(ethCirculationUrl);
    
    println("* Downloading BTC circulation data");
    btcCirculationJson = loadJSONObject(btcCirculationUrl);
    
    parseCirculation();
  }
  
  void getEnergy() {
    println("* Downloading ETH energy data");
    ethEnergyTable = loadTable(ethEnergyUrl, "csv, header");
    
    println("* Downloading BTC energy data");
    btcEnergyTable = loadTable(btcEnergyUrl, "csv, header");
    
    parseEnergy();
  }
  
  void parseCirculation() {
    println("* Parsing circulation data");
    JSONArray ethCirculationData = ethCirculationJson.getJSONArray("data");
    JSONArray btcCirculationData = btcCirculationJson.getJSONArray("data");
    
    if (getLatestOnly) {
      ethCurrentCirculation = circulationFromJsonLatest(ethCirculationData);
      btcCurrentCirculation = circulationFromJsonLatest(btcCirculationData);
    } else {
      ethCirculationArray = circulationFromJson(ethCirculationData);
      btcCirculationArray = circulationFromJson(btcCirculationData);
    }

    println(">> Circulation: " + ethCurrentCirculation + " " + btcCurrentCirculation);
  }
  
  long circulationFromJsonLatest(JSONArray data) {
    return (long) data.getJSONObject(data.size()-1).getDouble("sum(generation)");
  }
  
  long[] circulationFromJson(JSONArray data) {
    long[] returns = new long[data.size()];
    
    for (int i=0; i<data.size(); i++) {
      returns[i] = (long) data.getJSONObject(i).getDouble("sum(generation)");
    }
      
    return returns;
  }
  
  void parseEnergy() {
    println("* Parsing energy data");
    if (getLatestOnly) {
      ethCurrentEnergy = energyFromCsvLatest(ethEnergyTable);
      btcCurrentEnergy = energyFromCsvLatest(btcEnergyTable);
    } else {
      ethEnergyArray = energyFromCsv(ethEnergyTable);
      btcEnergyArray = energyFromCsv(btcEnergyTable);
    }

    println(">> Energy: " + ethCurrentEnergy + " " + btcCurrentEnergy);
  }
  
  float energyFromCsvLatest(Table table) {
    float returns = 0;
    int index = table.getRowCount()-1;
    
    while (returns == 0 && index > 0) {
      returns = table.getRow(index).getFloat("Estimated TWh per Year");
      if (Float.isNaN(returns)) returns = 0;
      index--;
    }
    
    return returns;
  }
  
  float[] energyFromCsv(Table table) {
    float[] returns = new float[table.getRowCount()];
    int index = 0;
    
    for (TableRow row :btcEnergyTable.rows()) {
      float estTWh = row.getFloat("Estimated TWh per Year");
      if (Float.isNaN(estTWh)) estTWh = 0;
      returns[index++] = estTWh;
    }
    
    return returns;
  }
  
  void update() {
    getEnergy();    
    if (doCirculation) getCirculation();
  }
    
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

class SeedParser {
  
  String ethSeedUrl = "https://api.blockcypher.com/v1/eth/main";
  JSONObject ethJson;

  String btcSeedUrl = "https://api.blockcypher.com/v1/btc/main";
  JSONObject btcJson;
  
  int eth_height = 0;
  int btc_height = 0;
  int last_eth_height = 0;
  int last_btc_height = 0;
  
  boolean changed = false;
  
  SeedParser() {
    //
  }
  
  void update() {
    ethJson = loadJSONObject(btcSeedUrl);
    btcJson = loadJSONObject(ethSeedUrl);
    
    last_eth_height = 0 + eth_height;
    last_btc_height = 0 + btc_height;
    eth_height = ethJson.getInt("height");
    btc_height = btcJson.getInt("height");
    
    changed = last_eth_height != eth_height || last_btc_height != btc_height;
    
    println(eth_height + " " + btc_height + " " + last_eth_height + " " + last_btc_height);
  }
  
}

class Target {
  
  int w, h;
  PVector pos;
  PVector goal;
  float speed = 0.1;
  float minDist = 2;
  
  Target(int _w, int _h) {
    w = _w;
    h = _h;
    pos = new PVector(random(w), random(h));
    init();
  }
  
  void init() {
    goal = new PVector(random(w), random(h));
  }
  
  void update() {
    pos = PVector.lerp(pos, goal, speed);
    if (PVector.dist(pos, goal) < minDist) init();
  }
  
}

/* Notes:
  
eth
Circulation: date, sum(generation)
Energy: Date, Estimated TWh per Year, Minimum TWh per Year 

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

btc
Circulation: date, sum(generation)
Energy: Date, Estimated TWh per Year, Minimum TWh per Year
  
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
