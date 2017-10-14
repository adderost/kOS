function ship_pitch {
  return 90 - vang(ship:up:vector, ship:facing:forevector).
}