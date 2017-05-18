import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AdvancementComponent } from './advancement.component';

describe('AdvancementComponent', () => {
  let component: AdvancementComponent;
  let fixture: ComponentFixture<AdvancementComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AdvancementComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AdvancementComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
