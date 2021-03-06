import Foundation
import UIKit
import RxSwift
import RxCocoa


class ReactiveGestureReactor: GestureReactor {

	var delegate: GestureReactorDelegate?
	
	private var timerCreator: ReactiveTimerCreator
	private let disposeBag = DisposeBag()
	
	private var panVariable: Variable<UIGestureRecognizerType?>
	private var rotateVariable: Variable<UIGestureRecognizerType?>
	
	init(timerCreator: ReactiveTimerCreator) {
		self.timerCreator = timerCreator
		panVariable = Variable(nil)
		rotateVariable = Variable(nil)
				
        
        // FYI 
        // Passing on the UIGesture at this point is dodgy as it's a reference 
        // It's state will change and render our filter useless. 
        // We therefore keep just the state in our observable buffers [.Began,.Began,.Ended]
        let rotateGuesturesStartedEnded = rotateVariable.asObservable().filter { gesture in gesture?.state == .Began || gesture?.state == .Ended}.flatMap { (gesture) -> Observable<UIGestureRecognizerState> in
            return Observable.just(gesture!.state)
        }
        
        let panGuesturesStartedEnded = panVariable.asObservable().filter { gesture in gesture?.state == .Began || gesture?.state == .Ended}.flatMap { (gesture) -> Observable<UIGestureRecognizerState> in
            return Observable.just(gesture!.state)
        }
        
        // Combine our latest .Began and .Ended from both Pan and Rotate.
        // If they are the same then return the same state. If not then return a Failed.
        let combineStartEndGuestures = Observable.combineLatest(panGuesturesStartedEnded, rotateGuesturesStartedEnded) { (panState, rotateState) -> Observable<UIGestureRecognizerState> in
            
            var state = UIGestureRecognizerState.Failed //a bit of misuse ;)
            
            // We have a match on either .Began or .Failed.
            if panState == rotateState {
                state = panState //Just assign state of pan as it'll be the same as rotate. .Began or .Ended
            }
            
            return Observable.just(state)
        }

        
        // condition: when both pan and rotate has begun
        let bothGesturesStarted = combineStartEndGuestures.switchLatest().filter { (state) -> Bool in
            state == .Began
        }
        
        // condition: when both pan and rotate has Ended
        let bothGesturesEnded = combineStartEndGuestures.switchLatest().filter { (state) -> Bool in
            state == .Ended
        }
        
		// when bothGesturesStarted, do this:
		bothGesturesStarted.subscribeNext { [unowned self] _ in
			
			self.delegate?.didStart()
			// create a timer that ticks every second
			let timer = self.timerCreator(interval: 1)
			// condition: but only three ticks
			let timerThatTicksThree = timer.take(3)
			// condition: and also, stop it immediately when both pan and rotate ended
			let timerThatTicksThreeAndStops = timerThatTicksThree.takeUntil(bothGesturesEnded)
			
			timerThatTicksThreeAndStops.subscribe(onNext: { [unowned self] count in
				// when a tick happens, do this:
				self.delegate?.didTick(count)
				}, onCompleted: { [unowned self] in
					// when the timer completes, do this:
					self.delegate?.didComplete()
			})
		}.addDisposableTo(self.disposeBag)

	}

	func handlePan(panGesture: UIPanGestureRecognizerType) {
		panVariable.value = panGesture
	}
	
	func handleRotate(rotateGesture: UIRotationGestureRecognizerType) {
		rotateVariable.value = rotateGesture
	}
	
}