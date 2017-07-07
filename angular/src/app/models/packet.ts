export class Packet {
  constructor(
    public type: string,
    data?: any
  ) {
    Object.assign(this, data || {});
  }
}
