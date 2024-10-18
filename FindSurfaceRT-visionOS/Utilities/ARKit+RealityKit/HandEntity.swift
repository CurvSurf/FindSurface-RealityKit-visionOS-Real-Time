//
//  HandEntity.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/8/24.
//

import Foundation
import ARKit
import RealityKit

fileprivate let thumbMaterials: [any Material] = [SimpleMaterial(color: .red, roughness: 0.75, isMetallic: false)]
fileprivate let indexFingerMaterials: [any Material] = [SimpleMaterial(color: .orange, roughness: 0.75, isMetallic: false)]
fileprivate let middleFingerMaterials: [any Material] = [SimpleMaterial(color: .yellow, roughness: 0.75, isMetallic: false)]
fileprivate let ringFingerMaterials: [any Material] = [SimpleMaterial(color: .green, roughness: 0.75, isMetallic: false)]
fileprivate let littleFingerMaterials: [any Material] = [SimpleMaterial(color: .blue, roughness: 0.75, isMetallic: false)]
fileprivate let forearmMaterials: [any Material] = [SimpleMaterial(color: .purple, roughness: 0.75, isMetallic: false)]
fileprivate let wristMaterials: [any Material] = [SimpleMaterial(color: .white, roughness: 0.75, isMetallic: false)]

extension HandSkeleton.JointName {
    fileprivate var materials: [any Material] {
        if isThumbJoint {
            return thumbMaterials
        } else if isIndexFingerJoint {
            return indexFingerMaterials
        } else if isMiddleFingerJoint {
            return middleFingerMaterials
        } else if isRingFingerJoint {
            return ringFingerMaterials
        } else if isLittleFingerJoint {
            return littleFingerMaterials
        } else if isForearmJoint {
            return forearmMaterials
        } else {
            return wristMaterials
        }
    }
}

@MainActor
final class JointEntity: Entity {
    
    private(set) var jointName: HandSkeleton.JointName
    fileprivate(set) var isTracked: Bool = false {
        didSet {
            components.set(OpacityComponent(opacity: isTracked ? 1 : 0))
        }
    }
    fileprivate(set) var anchorFromJointTransform: simd_float4x4 = .init(1.0)
    
    fileprivate init(jointName: HandSkeleton.JointName) {
        self.jointName = jointName
        super.init()
        self.name = jointName.description
        
        let visual = ModelEntity(mesh: .generateBox(size: 0.02),
                                 materials: jointName.materials)
        addChild(visual)
    }
    
    required init() {
        self.jointName = .forearmArm
        super.init()
        fatalError()
    }
}

final class HandEntity: Entity {
    
    private let joints: [HandSkeleton.JointName: JointEntity]
    fileprivate(set) var isTracked: Bool = false {
        didSet {
            self.components.set(OpacityComponent(opacity: isTracked ? 1 : 0))
        }
    }
    
    private weak var _parent: Entity? = nil
    var shouldDraw: Bool = true {
        didSet {
            if !oldValue && shouldDraw {
                _parent?.addChild(self)
                _parent = nil
            } else if oldValue && !shouldDraw {
                _parent = self.parent
                self.removeFromParent()
            }
        }
    }
    
    required init() {
        
        var joints: [HandSkeleton.JointName: JointEntity] = [:]
        
        for jointName in HandSkeleton.JointName.allCases {
            joints[jointName] = JointEntity(jointName: jointName)
        }
        
        self.joints = joints
        super.init()
        
        for (name, entity) in joints {
            var parentName = name.parentName
            while true {
                if parentName == name {
                    addChild(entity)
                    break;
                } else if let parent = joints[parentName] {
                    parent.addChild(entity)
                    break;
                } else {
                    parentName = parentName.parentName
                }
            }
        }
        
        self.components.set(OpacityComponent(opacity: 1))
    }
    
    subscript(_ jointName: HandSkeleton.JointName) -> JointEntity {
        get { joints[jointName]! }
    }
    
    func jointTransform(_ jointName: HandSkeleton.JointName) -> simd_float4x4? {
        let joint = self[jointName]
        guard joint.isTracked else { return nil }
        return transform.matrix * joint.anchorFromJointTransform
    }
    
    func jointPosition(_ jointName: HandSkeleton.JointName) -> simd_float3? {
        return jointTransform(jointName)?.position
    }
    
    func update(_ anchor: HandAnchor) {
        
        let tracked = anchor.isTracked
        isTracked = tracked
        guard tracked else { return }
        
        transform = Transform(matrix: anchor.originFromAnchorTransform)
        guard let skeleton = anchor.handSkeleton else { return }
        
        for (name, entity) in joints {
            let joint = skeleton.joint(name)
            
            let tracked = joint.isTracked
            entity.isTracked = tracked
            guard tracked else { continue }
            entity.anchorFromJointTransform = joint.anchorFromJointTransform
            entity.transform = Transform(matrix: joint.parentFromJointTransform)
        }
    }
}

extension HandSkeleton.JointName {
    
    fileprivate var parentName: HandSkeleton.JointName {
        switch self {
        case .wrist:                        return .wrist
        
        case .thumbKnuckle:                 return .wrist
        case .thumbIntermediateBase:        return .thumbKnuckle
        case .thumbIntermediateTip:         return .thumbIntermediateBase
        case .thumbTip:                     return .thumbIntermediateTip
        
        case .indexFingerMetacarpal:        return .wrist
        case .indexFingerKnuckle:           return .indexFingerMetacarpal
        case .indexFingerIntermediateBase:  return .indexFingerKnuckle
        case .indexFingerIntermediateTip:   return .indexFingerIntermediateBase
        case .indexFingerTip:               return .indexFingerIntermediateTip
        
        case .middleFingerMetacarpal:       return .wrist
        case .middleFingerKnuckle:          return .middleFingerMetacarpal
        case .middleFingerIntermediateBase: return .middleFingerKnuckle
        case .middleFingerIntermediateTip:  return .middleFingerIntermediateBase
        case .middleFingerTip:              return .middleFingerIntermediateTip
        
        case .ringFingerMetacarpal:         return .wrist
        case .ringFingerKnuckle:            return .ringFingerMetacarpal
        case .ringFingerIntermediateBase:   return .ringFingerKnuckle
        case .ringFingerIntermediateTip:    return .ringFingerIntermediateBase
        case .ringFingerTip:                return .ringFingerIntermediateTip
        
        case .littleFingerMetacarpal:       return .wrist
        case .littleFingerKnuckle:          return .littleFingerMetacarpal
        case .littleFingerIntermediateBase: return .littleFingerKnuckle
        case .littleFingerIntermediateTip:  return .littleFingerIntermediateBase
        case .littleFingerTip:              return .littleFingerIntermediateTip
        
        case .forearmWrist:                 return .wrist
        case .forearmArm:                   return .forearmWrist
        @unknown default:                   return .wrist
        }
    }
    
    fileprivate static var thumbJoints: Set<HandSkeleton.JointName> {
        return [.thumbKnuckle,
                .thumbIntermediateBase,
                .thumbIntermediateTip,
                .thumbTip]
    }
    
    fileprivate var isThumbJoint: Bool {
        return Self.thumbJoints.contains(self)
    }
    
    fileprivate static var indexFingerJoints: Set<HandSkeleton.JointName> {
        return [.indexFingerMetacarpal, 
                .indexFingerKnuckle,
                .indexFingerIntermediateBase, 
                .indexFingerIntermediateTip,
                .indexFingerTip]
    }
    
    fileprivate var isIndexFingerJoint: Bool {
        return Self.indexFingerJoints.contains(self)
    }
    
    fileprivate static var middleFingerJoints: Set<HandSkeleton.JointName> {
        return [.middleFingerMetacarpal, 
                .middleFingerKnuckle,
                .middleFingerIntermediateBase,
                .middleFingerIntermediateTip,
                .middleFingerTip]
    }
    
    fileprivate var isMiddleFingerJoint: Bool {
        return Self.middleFingerJoints.contains(self)
    }
    
    fileprivate static var ringFingerJoints: Set<HandSkeleton.JointName> {
        return [.ringFingerMetacarpal,
                .ringFingerKnuckle,
                .ringFingerIntermediateBase,
                .ringFingerIntermediateTip,
                .ringFingerTip]
    }
    
    fileprivate var isRingFingerJoint: Bool {
        return Self.ringFingerJoints.contains(self)
    }
    
    fileprivate static var littleFingerJoints: Set<HandSkeleton.JointName> {
        return [.littleFingerMetacarpal,
                .littleFingerKnuckle,
                .littleFingerIntermediateBase,
                .littleFingerIntermediateTip,
                .littleFingerTip]
    }
    
    fileprivate var isLittleFingerJoint: Bool {
        return Self.littleFingerJoints.contains(self)
    }
    
    fileprivate static var forearmJoints: Set<HandSkeleton.JointName> {
        return [.forearmWrist, .forearmArm]
    }
    
    fileprivate var isForearmJoint: Bool {
        return Self.forearmJoints.contains(self)
    }
}
