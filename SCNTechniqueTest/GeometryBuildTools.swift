//
//  GeometryBuildTools.swift
//  observeearth
//
//  Created by Lachlan Hurst on 24/03/2016.
//  Copyright © 2016 Lachlan Hurst. All rights reserved.
//

import Foundation
import SceneKit

class GeometryBuildTools {

    static func buildBox() -> SCNGeometry {
        let halfSideX:Float = 0.5
        let halfSideY:Float = 0.5
        let halfSideZ:Float = 2.0

        let positions = [
            SCNVector3Make(-halfSideX, -halfSideY,  halfSideZ),
            SCNVector3Make( halfSideX, -halfSideY,  halfSideZ),
            SCNVector3Make(-halfSideX, -halfSideY, -halfSideZ),
            SCNVector3Make( halfSideX, -halfSideY, -halfSideZ),
            SCNVector3Make(-halfSideX,  halfSideY,  halfSideZ),
            SCNVector3Make( halfSideX,  halfSideY,  halfSideZ),
            SCNVector3Make(-halfSideX,  halfSideY, -halfSideZ),
            SCNVector3Make( halfSideX,  halfSideY, -halfSideZ),

            // repeat exactly the same
            SCNVector3Make(-halfSideX, -halfSideY,  halfSideZ),
            SCNVector3Make( halfSideX, -halfSideY,  halfSideZ),
            SCNVector3Make(-halfSideX, -halfSideY, -halfSideZ),
            SCNVector3Make( halfSideX, -halfSideY, -halfSideZ),
            SCNVector3Make(-halfSideX,  halfSideY,  halfSideZ),
            SCNVector3Make( halfSideX,  halfSideY,  halfSideZ),
            SCNVector3Make(-halfSideX,  halfSideY, -halfSideZ),
            SCNVector3Make( halfSideX,  halfSideY, -halfSideZ),

            // repeat exactly the same
            SCNVector3Make(-halfSideX, -halfSideY,  halfSideZ),
            SCNVector3Make( halfSideX, -halfSideY,  halfSideZ),
            SCNVector3Make(-halfSideX, -halfSideY, -halfSideZ),
            SCNVector3Make( halfSideX, -halfSideY, -halfSideZ),
            SCNVector3Make(-halfSideX,  halfSideY,  halfSideZ),
            SCNVector3Make( halfSideX,  halfSideY,  halfSideZ),
            SCNVector3Make(-halfSideX,  halfSideY, -halfSideZ),
            SCNVector3Make( halfSideX,  halfSideY, -halfSideZ)
        ]

        let normals = [
            SCNVector3Make( 0, -1, 0),
            SCNVector3Make( 0, -1, 0),
            SCNVector3Make( 0, -1, 0),
            SCNVector3Make( 0, -1, 0),

            SCNVector3Make( 0, 1, 0),
            SCNVector3Make( 0, 1, 0),
            SCNVector3Make( 0, 1, 0),
            SCNVector3Make( 0, 1, 0),


            SCNVector3Make( 0, 0,  1),
            SCNVector3Make( 0, 0,  1),
            SCNVector3Make( 0, 0, -1),
            SCNVector3Make( 0, 0, -1),

            SCNVector3Make( 0, 0, 1),
            SCNVector3Make( 0, 0, 1),
            SCNVector3Make( 0, 0, -1),
            SCNVector3Make( 0, 0, -1),


            SCNVector3Make(-1, 0, 0),
            SCNVector3Make( 1, 0, 0),
            SCNVector3Make(-1, 0, 0),
            SCNVector3Make( 1, 0, 0),

            SCNVector3Make(-1, 0, 0),
            SCNVector3Make( 1, 0, 0),
            SCNVector3Make(-1, 0, 0),
            SCNVector3Make( 1, 0, 0),
        ]

        let indices:[CInt] = [
            // bottom
            0, 2, 1,
            1, 2, 3,
            // back
            10, 14, 11,  // 2, 6, 3,   + 8
            11, 14, 15,  // 3, 6, 7,   + 8
            // left
            16, 20, 18,  // 0, 4, 2,   + 16
            18, 20, 22,  // 2, 4, 6,   + 16
            // right
            17, 19, 21,  // 1, 3, 5,   + 16
            19, 23, 21,  // 3, 7, 5,   + 16
            // front
            8,  9, 12,  // 0, 1, 4,   + 8
            9, 13, 12,  // 1, 5, 4,   + 8
            // top
            4, 5, 6,
            5, 7, 6
        ]

        let colors = [vector_float4](count:positions.count, repeatedValue:vector_float4(1.0,1.0,1.0,0.0))

        let geom = packGeometryTriangles(positions, indexList: indices, colourList: colors, normalsList: normals)
        return geom
    }

    static func buildSpiral() -> SCNGeometry {

        var centerPoints:[SCNVector3] = []

        let angleStep = Float(M_PI) / 30
        let zStep:Float = 0.01
        let radius:Float = 1

        var angle:Float = 0
        var z:Float = -2

        while z < 2 {
            let x = radius * cos(angle)
            let y = radius * sin(angle)

            let pt = SCNVector3Make(x, y, z)
            centerPoints.append(pt)

            angle += angleStep
            z += zStep
        }

        let geom = buildTube(centerPoints, center: SCNVector3Zero, radius: 0.05, segmentCount: 10, colour: vector_float4(1.0, 0.0, 0.0, 1.0))
        return geom

    }


    /**
     Takes the various arrays and makes a geometry object from it
     */
    static func packGeometryTriangles(pointsList: [SCNVector3],
                                      indexList: [CInt],
                                      colourList:[vector_float4]?,
                                      normalsList: [SCNVector3]) -> SCNGeometry {

        let vertexData = NSData(bytes: pointsList, length: pointsList.count * sizeof(SCNVector3))
        let vertexSourceNew = SCNGeometrySource(data: vertexData,
                                                semantic: SCNGeometrySourceSemanticVertex,
                                                vectorCount: pointsList.count,
                                                floatComponents: true,
                                                componentsPerVector: 3,
                                                bytesPerComponent: sizeof(Float),
                                                dataOffset: 0,
                                                dataStride: sizeof(SCNVector3))

        let normalData = NSData(bytes: normalsList, length: normalsList.count * sizeof(SCNVector3))
        let normalSource = SCNGeometrySource(data: normalData,
                                             semantic: SCNGeometrySourceSemanticNormal,
                                             vectorCount: normalsList.count,
                                             floatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: sizeof(Float),
                                             dataOffset: 0,
                                             dataStride: sizeof(SCNVector3))



        let indexData  = NSData(bytes: indexList, length: sizeof(CInt) * indexList.count)
        let indexElement = SCNGeometryElement(
            data: indexData,
            primitiveType: SCNGeometryPrimitiveType.Triangles,
            primitiveCount: indexList.count/3,
            bytesPerIndex: sizeof(CInt)
        )

        if let colourList = colourList {
            let colourData = NSData(bytes: colourList, length: colourList.count * sizeof(vector_float4))
            let colourSource = SCNGeometrySource(data: colourData,
                                                 semantic: SCNGeometrySourceSemanticColor,
                                                 vectorCount: colourList.count,
                                                 floatComponents: true,
                                                 componentsPerVector: 4,
                                                 bytesPerComponent: sizeof(Float),
                                                 dataOffset: 0,
                                                 dataStride: sizeof(vector_float4))
            let geo = SCNGeometry(sources: [vertexSourceNew,normalSource,colourSource], elements: [indexElement])
            geo.firstMaterial?.litPerPixel = false
            return geo
        } else {
            let geo = SCNGeometry(sources: [vertexSourceNew,normalSource], elements: [indexElement])
            geo.firstMaterial?.litPerPixel = false
            return geo
        }

    }


    static func buildTube(points:[SCNVector3], center:SCNVector3, radius:Float, segmentCount:Int, colour:vector_float4?) -> SCNGeometry {
        var colour = colour
        if colour == nil {
            colour = vector_float4(0,0,0,1)
        }

        let segmentRotationAngle = 2 * Float(M_PI) / Float(segmentCount)

        var pointsList: [SCNVector3] = []
        var normalsList: [SCNVector3] = []
        var indexList: [CInt] = []
        var colourList:[vector_float4] = []

        var lastPt:SCNVector3? = nil
        var lastPtsOffset:[SCNVector3]? = nil
        var lastNormalsOffset:[SCNVector3]? = nil
        for (i,pt) in points.enumerate() {

            let distanceFromEnd = min(points.count - i, i)
            let radiusMultiplicationFactor = min(Float(distanceFromEnd) / 4, 1)

            if let lastPt = lastPt {
                let along = (pt - lastPt)

                let parallel = along.normalized()
                let normal = (pt - center).normalized()

                let startOffsetVector = normal * (radius * radiusMultiplicationFactor)
                let startOffsetVectorGlk = SCNVector3ToGLKVector3(startOffsetVector)

                var offsetPoints = [SCNVector3](count:segmentCount, repeatedValue:SCNVector3Zero)
                var offsetNormalVectors = [SCNVector3](count:segmentCount, repeatedValue:SCNVector3Zero)

                var rotation:Float = 0
                for i in 0..<segmentCount {
                    let quart = GLKQuaternionMakeWithAngleAndAxis(rotation, parallel.x, parallel.y, parallel.z)
                    let rotatedOffsetVector = GLKQuaternionRotateVector3(quart, startOffsetVectorGlk)
                    let offsetPoint = pt + SCNVector3FromGLKVector3(rotatedOffsetVector)
                    offsetPoints[i] = offsetPoint
                    offsetNormalVectors[i] = SCNVector3FromGLKVector3(rotatedOffsetVector).normalized()

                    rotation += segmentRotationAngle
                }

                if let lastPtsOffset = lastPtsOffset, lastNormalsOffset = lastNormalsOffset {

                    var prevLastPoint = lastPtsOffset[segmentCount-1]
                    var prevLastNorma = lastNormalsOffset[segmentCount-1]
                    var prevPoint = offsetPoints[segmentCount-1]
                    var prevNorma = offsetNormalVectors[segmentCount-1]
                    for i in 0..<segmentCount {
                        let lastPoint = lastPtsOffset[i]
                        let lastNorma = lastNormalsOffset[i]
                        let cPoint = offsetPoints[i]
                        let cNorma = offsetNormalVectors[i]

                        indexList.append(CInt(pointsList.count))
                        pointsList.append(prevPoint)
                        colourList.append(colour!)
                        normalsList.append(prevNorma * 2)

                        indexList.append(CInt(pointsList.count))
                        pointsList.append(prevLastPoint)
                        colourList.append(colour!)
                        normalsList.append(prevLastNorma * 2)

                        indexList.append(CInt(pointsList.count))
                        pointsList.append(lastPoint)
                        colourList.append(colour!)
                        normalsList.append(lastNorma * 2)


                        indexList.append(CInt(pointsList.count))
                        pointsList.append(lastPoint)
                        colourList.append(colour!)
                        normalsList.append(lastNorma)

                        indexList.append(CInt(pointsList.count))
                        pointsList.append(cPoint)
                        colourList.append(colour!)
                        normalsList.append(cNorma)

                        indexList.append(CInt(pointsList.count))
                        pointsList.append(prevPoint)
                        colourList.append(colour!)
                        normalsList.append(prevNorma)


                        prevLastPoint = lastPoint
                        prevLastNorma = lastNorma
                        prevPoint = cPoint
                        prevNorma = cNorma
                    }
                }
                lastPtsOffset = offsetPoints
                lastNormalsOffset = offsetNormalVectors
            }
            lastPt = pt
        }

        return GeometryBuildTools.packGeometryTriangles(pointsList, indexList: indexList, colourList: colourList, normalsList: normalsList)
    }

}