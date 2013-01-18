/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtend.core.macro.declaration

import java.util.List
import org.eclipse.xtend.lib.macro.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableNamedElement
import org.eclipse.xtend.lib.macro.declaration.MutableParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeParameterDeclarator
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.expression.Expression
import org.eclipse.xtend.lib.macro.type.TypeReference
import org.eclipse.xtext.common.types.JvmConstructor
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmExecutable
import org.eclipse.xtext.common.types.JvmField
import org.eclipse.xtext.common.types.JvmFormalParameter
import org.eclipse.xtext.common.types.JvmGenericType
import org.eclipse.xtext.common.types.JvmIdentifiableElement
import org.eclipse.xtext.common.types.JvmMember
import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.common.types.JvmVisibility
import org.eclipse.xtext.common.types.TypesFactory
import org.eclipse.xtext.xbase.lib.Functions$Function1
import org.eclipse.xtext.xbase.lib.Procedures$Procedure1

abstract class JvmNamedElementImpl<T extends JvmIdentifiableElement> extends AbstractDeclarationImpl<T> implements MutableNamedElement {
	
	override getName() {
		delegate.simpleName
	}
	
	override remove() {
		if (delegate.eContainer == null)
			return;
		delegate.eContainer.eContents.remove(delegate)
		if (delegate.eContainer != null)
			throw new IllegalStateException("Couldn't remove "+delegate.toString)
	}
	
}

abstract class JvmMemberDeclarationImpl<T extends JvmMember> extends JvmNamedElementImpl<T> implements MutableMemberDeclaration {
	
	override getDocComment() {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override setDocComment(String docComment) {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override getVisibility() {
		compilationUnit.toVisibility(delegate.visibility)
	}
	
	override setVisibility(Visibility visibility) {
		delegate.visibility = switch visibility {
			case Visibility::DEFAULT : JvmVisibility::DEFAULT
			case Visibility::PUBLIC : JvmVisibility::PUBLIC
			case Visibility::PRIVATE : JvmVisibility::PRIVATE
			case Visibility::PROTECTED : JvmVisibility::PROTECTED
		}
	}
	
	override getDeclaringType() {
		compilationUnit.toTypeDeclaration(delegate.declaringType) as MutableTypeDeclaration
	}
	
	override setName(String name) {
		delegate.simpleName = name
	}
	
}

abstract class JvmTypeDeclarationImpl<T extends JvmDeclaredType> extends JvmMemberDeclarationImpl<T> implements MutableTypeDeclaration {
	
	override getMembers() {
		delegate.members.map[compilationUnit.toMemberDeclaration(it) as MutableMemberDeclaration]
	}
	
	override getPackageName() {
		delegate.packageName
	}
	
	override getSimpleName() {
		delegate.simpleName
	}
	
	override getName() {
		delegate.identifier
	}
	
	override setPackageName(String packageName) {
		delegate.packageName = packageName
	}
	
	override setSimpleName(String simpleName) {
		delegate.simpleName = simpleName
	}
	
	override setName(String name) {
		val idx = name.lastIndexOf('.')
		if (idx == -1) {
			delegate.packageName = null
			delegate.simpleName = name
		} else {
			delegate.packageName = name.substring(0, idx-1)
			delegate.simpleName = name.substring(idx)
		}
	}
	
}

class JvmClassDeclarationImpl extends JvmTypeDeclarationImpl<JvmGenericType> implements MutableClassDeclaration {
	
	override getImplementedInterfaces() {
		val filtered = delegate.superTypes.filter[(it.type as JvmGenericType).interface]
		filtered.map[compilationUnit.toTypeReference(it)].toList
	}
	
	override getSuperclass() {
		compilationUnit.toTypeReference(delegate.superTypes.findFirst[(it.type as JvmGenericType).interface])
	}
	
	override isAbstract() {
		delegate.isAbstract
	}
	
	override isFinal() {
		delegate.isFinal
	}
	
	override isStatic() {
		delegate.isStatic
	}
	
	override getTypeParameters() {
		delegate.typeParameters.map[compilationUnit.toTypeParameterDeclaration(it)]
	}
	

	override setAbstract(boolean isAbstract) {
		delegate.setAbstract(isAbstract)
	}
	
	override setFinal(boolean isFinal) {
		delegate.setFinal(isFinal)
	}
	
	override setStatic(boolean isStatic) {
		delegate.setStatic(isStatic)
	}
	
	override setSuperclass(TypeReference superclass) {
		val interfaces = implementedInterfaces
		delegate.superTypes.clear
		delegate.superTypes.add(compilationUnit.toJvmTypeReference(superclass))
		interfaces.forEach[delegate.superTypes.add(compilationUnit.toJvmTypeReference(it))]
	}
	
	override setImplementedInterfaces(List<? extends TypeReference> superInterfaces) {
		val superClass = getSuperclass
		delegate.superTypes.clear
		delegate.superTypes.add(compilationUnit.toJvmTypeReference(superClass))
		superInterfaces.forEach[delegate.superTypes.add(compilationUnit.toJvmTypeReference(it))]
	}

	override addField(String name, Procedure1<MutableFieldDeclaration> initializer) {
		val newField = TypesFactory::eINSTANCE.createJvmField
		newField.simpleName = name
		delegate.members.add(newField)
		initializer.apply(compilationUnit.toMemberDeclaration(newField) as MutableFieldDeclaration)
	}
	
	override addMethod(String name, Procedure1<MutableMethodDeclaration> initializer) {
		val newMethod = TypesFactory::eINSTANCE.createJvmOperation
		newMethod.simpleName = name
		delegate.members.add(newMethod)
		initializer.apply(compilationUnit.toMemberDeclaration(newMethod) as MutableMethodDeclaration)
	}
	
	override findField(String name) {
		members.filter(typeof(MutableFieldDeclaration)).findFirst[it.name == name]
	}
	
	override findMethod(String name, TypeReference[] parameterTypes) {
		members.filter(typeof(MutableMethodDeclaration)).findFirst[it.name == name && it.parameters.map[type].toList == parameterTypes.toList]
	}

}

//class InterfaceDeclarationJavaImpl extends JvmTypeDeclarationImpl<JvmGenericType> implements JvmInterfaceDeclaration {
//	
//	override getSuperInterfaces() {
//		delegate.superTypes.map[compilationUnit.toTypeReference(it)]
//	}
//	
//	override getTypeParameters() {
//		delegate.typeParameters.map[compilationUnit.toTypeParameterDeclaration(it)]
//	}
//	
//}

abstract class JvmExecutableDeclarationImpl<T extends JvmExecutable> extends JvmMemberDeclarationImpl<T> implements MutableExecutableDeclaration {
	
	override getTypeParameters() {
		delegate.typeParameters.map[compilationUnit.toTypeParameterDeclaration(it) as MutableTypeParameterDeclaration]
	}
	
	override isVarArgs() {
		delegate.varArgs
	}
	
	override getBody() {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override getParameters() {
		delegate.parameters.map[compilationUnit.toParameterDeclaration(it) as MutableParameterDeclaration]
	}
	
	override getExceptions() {
		delegate.exceptions.map[compilationUnit.toTypeReference(it)]
	}
	
	override setBody(Expression body) {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override setExceptions(List<TypeReference> exceptions) {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override setVarArgs(boolean isVarArgs) {
		delegate.setVarArgs(isVarArgs)
	}
	
	override addTypeParameter(MutableTypeParameterDeclaration typeParameter) {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override addTypeParameter(int index, MutableTypeParameterDeclaration typeParameter) {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override removeTypeParameter(MutableTypeParameterDeclaration typeParameter) {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
}

class JvmParameterDeclarationImpl extends JvmNamedElementImpl<JvmFormalParameter> implements MutableParameterDeclaration {

	override getType() {
		compilationUnit.toTypeReference(delegate.parameterType)
	}
	
	override getDeclaringExecutable() {
		compilationUnit.toMemberDeclaration(delegate.eContainer as JvmMember) as MutableExecutableDeclaration
	}
	
	override setName(String name) {
		delegate.name = name
	}
	
}

class JvmMethodDeclarationImpl extends JvmExecutableDeclarationImpl<JvmOperation> implements MutableMethodDeclaration {
	
	override isAbstract() {
		delegate.isAbstract
	}
	
	override isFinal() {
		delegate.isFinal
	}
	
	override isOverride() {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override isStatic() {
		delegate.isStatic
	}
	
	override getReturnType() {
		compilationUnit.toTypeReference(delegate.returnType)
	}

	override setReturnType(TypeReference type) {
		delegate.setReturnType((type as TypeReferenceImpl).lightWeightTypeReference.toJavaCompliantTypeReference)
	}
	
	override setBody((CompilationContext)=>CharSequence compilationStrategy) {
		compilationUnit.setCompilationStrategy(delegate, compilationStrategy)
	}
	
}

class JvmConstructorDeclarationImpl extends JvmExecutableDeclarationImpl<JvmConstructor> implements MutableConstructorDeclaration {
	
	override getName() {
		declaringType.simpleName
	}
	
	override getBody() {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}

	override setBody((CompilationContext)=>CharSequence compilationStrategy) {
		compilationUnit.setCompilationStrategy(delegate, compilationStrategy)
	}
	
}

class JvmFieldDeclarationImpl extends JvmMemberDeclarationImpl<JvmField> implements MutableFieldDeclaration {
	
	override getInitializer() {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override isFinal() {
		delegate.isFinal
	}
	
	override isStatic() {
		delegate.isStatic
	}
	
	override getType() {
		compilationUnit.toTypeReference(delegate.type)
	}
	
	override MutableClassDeclaration getDeclaringType() {
		super.getDeclaringType() as MutableClassDeclaration
	}

	override setFinal(boolean isFinal) {
		delegate.setFinal(isFinal)
	}
	
	override setInitializer(Expression initializer) {
		throw new UnsupportedOperationException("Auto-Jvm function stub")
	}
	
	override setStatic(boolean isStatic) {
		delegate.setStatic(isStatic)
	}
	
	override setType(TypeReference type) {
		delegate.setType((type as TypeReferenceImpl).lightWeightTypeReference.toJavaCompliantTypeReference)
	}
	
}

class JvmTypeParameterDeclarationImpl extends TypeParameterDeclarationImpl implements MutableTypeParameterDeclaration {
	
	override MutableTypeParameterDeclarator getTypeParameterDeclarator() {
		compilationUnit.toMemberDeclaration(delegate.eContainer as JvmExecutable) as MutableTypeParameterDeclarator
	}
	
	override setName(String name) {
		delegate.name = name
	}
	
	override remove() {
		if (delegate.eContainer == null)
			return;
		delegate.eContainer.eContents.remove(delegate)
		if (delegate.eContainer != null)
			throw new IllegalStateException("Couldn't remove "+delegate)
	}
	
}
