import UIKit

public class ICWFStepExecutor: NSObject {

    private var _pendingSteps: NSMutableArray = NSMutableArray()
    private let _lock = NSRecursiveLock()
    fileprivate var _currentStep: ICWFStep?
    private var _deletionLock: ICWFStepExecutor?
    public var logger: ICBaseLogger
    
    deinit {
#if ALWAYS_LOG_WORKFLOWS || DEBUG
        logger.log("ICWF: The object [\(NSStringFromClass(self.classForCoder))] is deallocating")
#endif
    }
    
    init(logger: ICBaseLogger) {
        self.logger = logger
        super.init()
    }

    public func executeStep(_ step: ICWFStep?) {
        guard var nextStep = step else {
            _deletionLock = nil
            return
        }

        _deletionLock = self

        _lock.lock()
    
        if let currentWorkflow = nextStep.owner, currentWorkflow.isCancelled {
            nextStep = currentWorkflow.endStep()
            currentWorkflow.registerStep(nextStep)
        }

        if _currentStep != nil {
            
            _pendingSteps.add(nextStep)
            _lock.unlock()
            
            return
        }

        _currentStep = nextStep
        _currentStep!.executor = self

        _lock.unlock()
        
        DispatchQueue.main.async { [weak self] in
            guard
                let strongSelf = self,
                let stepToStart = strongSelf._currentStep
            else {
                return
            }
            
#if ALWAYS_LOG_WORKFLOWS || DEBUG
            strongSelf.logger.log("ICWF: Start step: \(strongSelf.infoOfStep(stepToStart))")
#endif
            stepToStart._sys_make()
        }
    }

    public func completeStep(_ step: ICWFStep?) {
#if ALWAYS_LOG_WORKFLOWS || DEBUG
        logger.log("ICWF: Finished step: \(infoOfStep(step))")
#endif
        
        _lock.lock()
        if _currentStep == step {
            _currentStep = nil
        } else {
            _pendingSteps.removeObject(identicalTo: step!)
        }
        
        var nextStepToExecute: ICWFStep?
        if let nextStep = _pendingSteps.firstObject as? ICWFStep {
            nextStepToExecute = nextStep
            _pendingSteps.removeObject(identicalTo: nextStep)
        }
        
        _lock.unlock()
        executeStep(nextStepToExecute)
    }
    
    func infoOfStep(_ stepObj: ICWFStep?) -> String {
        guard let step = stepObj else {
            return "(nil)"
        }
        
        var result = ""
        result.append("\(step.index).")
        result.append(" \(step.description)")
        result.append(" (\(NSStringFromClass(step.classForCoder)))")
        result.append(" {\(Unmanaged.passUnretained(step).toOpaque())}")
        let workflowName = step.owner?.name ?? "N/A"
        result.append(" [WF:\(workflowName)]")
        return result
    }
}
