package org.eclipse.xtend.core.tests.macro.declaration

import com.google.inject.Provider
import javax.inject.Inject
import org.eclipse.xtend.core.macro.declaration.CompilationUnitImpl
import org.eclipse.xtend.core.tests.AbstractXtendTestCase
import org.eclipse.xtend.core.xtend.XtendFile
import org.eclipse.xtend.lib.macro.declaration.AnnotationTypeElementDeclaration
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.junit.Test

class DeclarationsTest extends AbstractXtendTestCase {
	
	@Inject Provider<CompilationUnitImpl> compilationUnitProvider
	
	@Test def testAnnotation() {
		validFile('''
		@SuppressWarnings("unused")
		class MyClass {
			
			@com.google.inject.Inject(optional=true) MyClass foo
		}
		
		''').asCompilationUnit [
			assertNull(packageName)
			val clazz = sourceTypeDeclarations.head as ClassDeclaration
			assertEquals('MyClass', clazz.name)
			val suppressWarning = clazz.annotations.head
			val supressWarningsDeclaration = suppressWarning.annotationTypeDeclaration
			assertEquals('java.lang.SuppressWarnings', supressWarningsDeclaration.name)
			assertEquals('unused', suppressWarning.getValue('value'))
			
			assertEquals(2, supressWarningsDeclaration.annotations.size)
			
			val valueProperty = supressWarningsDeclaration.declaredMembers.filter(typeof(AnnotationTypeElementDeclaration)).head
			assertEquals("String[]", valueProperty.type.toString)
			assertEquals("value", valueProperty.name)
			
			val field = clazz.declaredMembers.head as FieldDeclaration
			val inject = field.annotations.head
			assertTrue(inject.getValue('optional') as Boolean)
		]
	}
	
	@Test def testSimpleClassWithField() {
		validFile('''
		package foo
		
		class MyClass extends Object implements java.io.Serializable {
			MyClass foo
		}
		''').asCompilationUnit [
			assertEquals('foo', packageName)
			val clazz = sourceTypeDeclarations.head as ClassDeclaration
			assertEquals('foo.MyClass', clazz.name)
			assertEquals('Object', clazz.superclass.toString)
			assertEquals('Serializable', clazz.implementedInterfaces.head.toString)
			val field = clazz.declaredMembers.head as FieldDeclaration
			assertEquals('foo', field.name)
			assertSame(typeLookup.findClass('foo.MyClass'), field.type.type)
		]
	}
	
	@Test def testXtendClassWithMethodFieldAndConstructor() {
		validFile('''
		package foo
		
		class MyClass<T extends CharSequence> {
			
			String myField
			
			new(String initial) {
				this.myField = initial
			}
			
			def <T2 extends CharSequence> MyClass myMethod(T2 a, T b) {
				myField = myField + a + b
				return this
			}
		}
		''').asCompilationUnit [
			assertEquals('foo', packageName)
			val clazz = sourceTypeDeclarations.head as ClassDeclaration
			val genClazz = typeLookup.findClass('foo.MyClass')
			
			assertEquals('foo.MyClass', clazz.name)
			assertNull(clazz.superclass)
			assertTrue(clazz.implementedInterfaces.empty)
			assertEquals(3, clazz.declaredMembers.size)
			assertEquals('T', clazz.typeParameters.head.name)
			assertEquals('CharSequence', clazz.typeParameters.head.upperBounds.head.toString)
			assertSame(clazz, clazz.typeParameters.head.typeParameterDeclarator)
			
			val field = clazz.declaredFields.head
			assertSame(clazz, field.declaringType)
			assertEquals('myField', field.name)
			assertEquals("String", field.type.toString)
			assertFalse(field.isFinal)
			
			val constructor = clazz.declaredConstructors.head
			
			assertSame(clazz, constructor.declaringType)
			assertEquals('MyClass', constructor.name)
			assertEquals('initial', constructor.parameters.head.name)
			assertEquals('String', constructor.parameters.head.type.toString)
			
			val method = clazz.declaredMethods.head
			val genMethod = genClazz.declaredMethods.head
			
			assertSame(clazz, method.declaringType)
			assertEquals('a', method.parameters.head.name)
			assertEquals('T2', method.parameters.head.type.toString)
			assertSame(genMethod.typeParameters.head, method.parameters.head.type.type)
			assertEquals('T', method.parameters.get(1).type.toString)
			assertSame(genClazz.typeParameters.head, method.parameters.get(1).type.type)
			assertSame(genClazz, method.returnType.type)
			
			assertEquals('T2', method.typeParameters.head.name)
			assertEquals('CharSequence', method.typeParameters.head.upperBounds.head.toString)
			assertSame(method.typeParameters.head, method.typeParameters.head)
			assertSame(method, method.typeParameters.head.typeParameterDeclarator)
			
			assertSame(field, clazz.declaredMembers.get(0))
			assertSame(constructor, clazz.declaredMembers.get(1))
			assertSame(method, clazz.declaredMembers.get(2))
		]
	}
	
	@Test def testMutableClassDeclaration() {
		validFile('''
		package foo
		
		class MyClass<T extends CharSequence> {
			
			String myField
			
			new(String initial) {
				this.myField = initial
			}
			
			def <T2 extends CharSequence> MyClass myMethod(T2 a, T b) {
				myField = myField + a + b
				return this
			}
		}
		''').asCompilationUnit [
			val genClazz = typeLookup.findClass('foo.MyClass')
			
			genClazz.addMethod('newMethod') [
				returnType = (genClazz.compilationUnit as CompilationUnitImpl).typeReferenceProvider.string 
				visibility = Visibility::PRIVATE
				body = ['''
					return "foo";
				''']
			]
			
			val mutableMethod = genClazz.findMethod('newMethod')
			assertSame(mutableMethod, genClazz.declaredMethods.get(1))
			assertEquals('String', mutableMethod.returnType.toString)
			assertEquals(Visibility::PRIVATE, mutableMethod.visibility)
		]
	}
	
	@Test def testTypeReferences() {
		validFile('''
		package foo
		
		class MyClass {
			
		}
		''').asCompilationUnit [
			val anyType = typeReferenceProvider.anyType
			assertTrue(anyType.anyType)
			
			val stringType = typeReferenceProvider.string
			val charsequenceType = typeReferenceProvider.newTypeReference(typeof(CharSequence).name)
			assertTrue(charsequenceType.isAssignableFrom(stringType))
			assertTrue(stringType.isAssignableFrom(anyType))
			assertFalse(stringType.isAssignableFrom(charsequenceType))
			
			checkPrimitive(typeReferenceProvider.primitiveBoolean, 'java.lang.Boolean')
			checkPrimitive(typeReferenceProvider.primitiveInt, 'java.lang.Integer')
			checkPrimitive(typeReferenceProvider.primitiveLong, 'java.lang.Long')
			checkPrimitive(typeReferenceProvider.primitiveShort, 'java.lang.Short')
			checkPrimitive(typeReferenceProvider.primitiveChar, 'java.lang.Character')
			checkPrimitive(typeReferenceProvider.primitiveByte, 'java.lang.Byte')
			checkPrimitive(typeReferenceProvider.primitiveFloat, 'java.lang.Float')
			checkPrimitive(typeReferenceProvider.primitiveDouble, 'java.lang.Double')
			val primitiveVoid = typeReferenceProvider.primitiveVoid
			assertTrue(primitiveVoid.isVoid)
			
			val listOfStringType = typeReferenceProvider.getList(typeReferenceProvider.string)
			val setOfString = typeReferenceProvider.getSet(listOfStringType.actualTypeArguments.head)
			assertEquals('List<String>', listOfStringType.toString)
			assertEquals('String',listOfStringType.actualTypeArguments.head.toString)
			assertEquals('Set<String>', setOfString.toString)
			assertEquals('String',setOfString.actualTypeArguments.head.toString)
			assertEquals('Set<?>', typeReferenceProvider.getSet(typeReferenceProvider.newWildcardTypeReference).toString)
			assertEquals('Set<? extends List<String>>', typeReferenceProvider.getSet(typeReferenceProvider.newWildcardTypeReference(listOfStringType)).toString)
		]
	}
	
	@Test def testIsAssignable() {
		validFile('''
		package foo
		
		class BaseClass implements InterfaceA {
		}
		class SubType extends BaseClass implements InterfaceA {
		}
		interface InterfaceA {}
		interface InterfaceB {}
		''').asCompilationUnit [
			val baseClass = sourceTypeDeclarations.get(0) as ClassDeclaration
			val subClass = typeLookup.findClass('foo.SubType')
			val interfaceA = sourceTypeDeclarations.get(2) as InterfaceDeclaration
			val interfaceB = sourceTypeDeclarations.get(3) as InterfaceDeclaration
			
			val object = typeReferenceProvider.object.type
			
			assertTrue(object.isAssignableFrom(baseClass))
			assertTrue(object.isAssignableFrom(subClass))
			assertTrue(object.isAssignableFrom(interfaceA))
			assertTrue(object.isAssignableFrom(interfaceB))
			
			assertTrue(baseClass.isAssignableFrom(baseClass))
			assertTrue(baseClass.isAssignableFrom(subClass))
			assertFalse(baseClass.isAssignableFrom(interfaceB))
			assertFalse(baseClass.isAssignableFrom(interfaceA))
			assertFalse(baseClass.isAssignableFrom(object))
			
			assertTrue(interfaceA.isAssignableFrom(baseClass))
			assertTrue(interfaceA.isAssignableFrom(subClass))
			assertTrue(interfaceA.isAssignableFrom(interfaceA))
			assertFalse(interfaceA.isAssignableFrom(interfaceB))
			assertFalse(interfaceA.isAssignableFrom(object))
		]
	}
	
	def void checkPrimitive(TypeReference primitiveType, String wrapperTypeName) {
		assertTrue(primitiveType.toString, primitiveType.primitive)
		assertEquals(wrapperTypeName, primitiveType.wrapperIfPrimitive.type.name)
	}
	
	def validFile(CharSequence code) {
		file(code.toString, true)
	}
	
	def asCompilationUnit(XtendFile file, (CompilationUnitImpl)=>void block) {
		val compilationUnit = compilationUnitProvider.get
		compilationUnit.xtendFile = file
		block.apply(compilationUnit)
	}
}