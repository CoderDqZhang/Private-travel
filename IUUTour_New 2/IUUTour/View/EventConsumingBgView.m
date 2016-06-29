#import "EventConsumingBgView.h"

@implementation EventConsumingBgView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *subViews = self.subviews;
    
    for (UIView *childView in subViews)
    {
        if ( [childView pointInside:[childView convertPoint:point toView:childView] withEvent:event] )
        {
            return childView;
        }
    }
    
    return self;
}

@end
