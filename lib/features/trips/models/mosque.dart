class Mosque {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

// Pre-defined list of mosques sorted alphabetically
final List<Mosque> availableMosques = [
  const Mosque(
    id: 'm1',
    name: 'Grande Mosquée de Lyon',
    address: '146 Boulevard Pinel, 69008 Lyon',
    latitude: 45.7380,
    longitude: 4.8836,
  ),
  const Mosque(
    id: 'm2',
    name: 'Grande Mosquée de Paris',
    address: '2 bis Place du Puits de l\'Ermite, 75005 Paris',
    latitude: 48.8422,
    longitude: 2.3556,
  ),
  const Mosque(
    id: 'm3',
    name: 'Mosquée Ar-Rahma',
    address: '23 Rue de Tanger, 75019 Paris',
    latitude: 48.8850,
    longitude: 2.3770,
  ),
  const Mosque(
    id: 'm4',
    name: 'Mosquée As-Salam',
    address: '8 Rue du Docteur Heulin, 75017 Paris',
    latitude: 48.8930,
    longitude: 2.3190,
  ),
  const Mosque(
    id: 'm5',
    name: 'Mosquée Bilal',
    address: '56 Rue de Lancry, 75010 Paris',
    latitude: 48.8710,
    longitude: 2.3610,
  ),
  const Mosque(
    id: 'm6',
    name: 'Mosquée de Créteil',
    address: '3 Rue Jean Gabin, 94000 Créteil',
    latitude: 48.7900,
    longitude: 2.4630,
  ),
  const Mosque(
    id: 'm7',
    name: 'Mosquée de Gennevilliers',
    address: '3 Avenue du Luth, 92230 Gennevilliers',
    latitude: 48.9332,
    longitude: 2.2917,
  ),
  const Mosque(
    id: 'm8',
    name: 'Mosquée de Lyon',
    address: '2 Place du Pont, 69007 Lyon',
    latitude: 45.7500,
    longitude: 4.8400,
  ),
  const Mosque(
    id: 'm9',
    name: 'Mosquée de Marseille',
    address: '2 Rue de la Butte, 13001 Marseille',
    latitude: 43.3000,
    longitude: 5.3700,
  ),
  const Mosque(
    id: 'm10',
    name: 'Mosquée de Mantes-la-Jolie',
    address: '6 Rue Denis Papin, 78200 Mantes-la-Jolie',
    latitude: 48.9900,
    longitude: 1.7200,
  ),
  const Mosque(
    id: 'm11',
    name: 'Mosquée de Nanterre',
    address: '2 Rue de l\'Église, 92000 Nanterre',
    latitude: 48.8920,
    longitude: 2.2066,
  ),
  const Mosque(
    id: 'm12',
    name: 'Mosquée de Strasbourg',
    address: '6 Rue Averroès, 67100 Strasbourg',
    latitude: 48.5633,
    longitude: 7.7194,
  ),
  const Mosque(
    id: 'm13',
    name: 'Mosquée El-Fath',
    address: '54 Rue Polonceau, 75018 Paris',
    latitude: 48.8870,
    longitude: 2.3510,
  ),
  const Mosque(
    id: 'm14',
    name: 'Mosquée Essunna',
    address: '73 Rue Myrrha, 75018 Paris',
    latitude: 48.8880,
    longitude: 2.3540,
  ),
  const Mosque(
    id: 'm15',
    name: 'Mosquée Omar Ibn Al-Khattab',
    address: '34 Rue de Tanger, 75019 Paris',
    latitude: 48.8855,
    longitude: 2.3780,
  ),
];
