import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BasicActionsComponent } from './basic-actions.component';

describe('BasicActionsComponent', () => {
  let component: BasicActionsComponent;
  let fixture: ComponentFixture<BasicActionsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BasicActionsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BasicActionsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
