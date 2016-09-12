require('UIColor');
defineClass('GRPViewController', {
  viewDidAppear: function(animated) {
    self.super().viewDidAppear(animated);
  self.view().setBackgroundColor(UIColor.redColor());
  },
});