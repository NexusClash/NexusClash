import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ModalDismissalComponent } from './modal-dismissal.component';

describe('ModalDismissalComponent', () => {
  let component: ModalDismissalComponent;
  let fixture: ComponentFixture<ModalDismissalComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ModalDismissalComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ModalDismissalComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
