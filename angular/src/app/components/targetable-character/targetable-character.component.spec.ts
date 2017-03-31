import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { TargetableCharacterComponent } from './targetable-character.component';

describe('TargetableCharacterComponent', () => {
  let component: TargetableCharacterComponent;
  let fixture: ComponentFixture<TargetableCharacterComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TargetableCharacterComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TargetableCharacterComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
