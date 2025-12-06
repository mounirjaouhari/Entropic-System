try {
  var status = rs.status();
  print("ReplicaSet déjà initialisé");
  printjson(status.members.map(m => ({ name: m.name, state: m.stateStr })));
} catch (e) {
  print("Initialisation du ReplicaSet...");
  var result = rs.initiate({
    _id: 'rs0',
    members: [
      { _id: 0, host: 'mongo1:27017', priority: 2 },
      { _id: 1, host: 'mongo2:27018', priority: 1 },
      { _id: 2, host: 'mongo3:27019', priority: 1 }
    ]
  });
  printjson(result);
  
  print("Attente élection PRIMARY (30 secondes)...");
  sleep(30000);
  
  var finalStatus = rs.status();
  printjson(finalStatus.members.map(m => ({ name: m.name, state: m.stateStr })));
}
