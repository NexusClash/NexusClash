import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

import { AppComponent } from './app.component';

import { CharacterService } from './packets/services/character.service';
import { MessageService } from './packets/services/message.service';
import { TileService } from './packets/services/tile.service';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule
  ],
  providers: [CharacterService, MessageService, TileService],
  bootstrap: [AppComponent]
})
export class AppModule { }
