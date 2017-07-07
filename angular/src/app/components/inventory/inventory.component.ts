import { Component } from '@angular/core';
import { Observable } from 'rxjs/Observable';

import { InventoryService } from '../../services/inventory.service';
import { Item } from '../../models/item';

@Component({
  selector: 'app-inventory',
  templateUrl: './inventory.component.html',
  styleUrls: ['./inventory.component.css']
})
export class InventoryComponent {

  items: Observable<Item[]> = this.inventoryService.items
    .startWith(this.inventoryService.itemsCache);

  constructor(
    private inventoryService: InventoryService
  ) { }
}
