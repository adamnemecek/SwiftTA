//
//  Utility+GLKit.swift
//  TAassets
//
//  Created by Logan Jones on 5/14/18.
//  Copyright © 2018 Logan Jones. All rights reserved.
//

import GLKit


extension GLKVector3 {
    
    init(_ v: Vertex3) {
        self.init(v: (Float(v.x), Float(v.y), Float(v.z)))
    }
    init(_ v: Vector3) {
        self.init(v: (Float(v.x), Float(v.y), Float(v.z)))
    }
    
}

func glUniformGLKVector3(_ location: GLint, _ value: GLKVector3) {
    var shadow = value
    glUniform3fv(location, 1, &shadow.__Anonymous_field0.x)
}
func glUniformGLKVector4(_ location: GLint, _ value: GLKVector4) {
    var shadow = value
    glUniform4fv(location, 1, &shadow.__Anonymous_field0.x)
}

func glUniformGLKMatrix4(_ location: GLint, transpose: Bool = false, _ value: GLKMatrix4) {
    var shadow = value
    glUniformMatrix4fv(location, 1, transpose ? 1 : 0, &shadow.__Anonymous_field0.m00)
}

func glUniformGLKMatrix4(_ location: GLint, transpose: Bool = false, _ values: [GLKMatrix4]) {
    values.withUnsafeBytes {
        let p = $0.baseAddress!
        glUniformMatrix4fv(location, GLsizei(values.count), transpose ? 1 : 0, p.assumingMemoryBound(to: GLfloat.self))
    }
}
