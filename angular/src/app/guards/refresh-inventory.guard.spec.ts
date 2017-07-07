import { TestBed, async, inject } from '@angular/core/testing';

import { RefreshInventoryGuard } from './refresh-inventory.guard';

describe('RefreshInventoryGuard', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [RefreshInventoryGuard]
    });
  });

  it('should ...', inject([RefreshInventoryGuard], (guard: RefreshInventoryGuard) => {
    expect(guard).toBeTruthy();
  }));
});
