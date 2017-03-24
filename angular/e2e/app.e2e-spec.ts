import { NexusClashPage } from './app.po';

describe('nexus-clash App', () => {
  let page: NexusClashPage;

  beforeEach(() => {
    page = new NexusClashPage();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('app works!');
  });
});
