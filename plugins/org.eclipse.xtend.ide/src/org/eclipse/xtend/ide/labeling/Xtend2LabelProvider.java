/*
* generated by Xtext
*/
package org.eclipse.xtend.ide.labeling;

import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.swt.graphics.Image;
import org.eclipse.xtend.core.jvmmodel.IXtend2JvmAssociations;
import org.eclipse.xtend.core.xtend.XtendClass;
import org.eclipse.xtend.core.xtend.XtendConstructor;
import org.eclipse.xtend.core.xtend.XtendField;
import org.eclipse.xtend.core.xtend.XtendFile;
import org.eclipse.xtend.core.xtend.XtendFunction;
import org.eclipse.xtend.core.xtend.XtendImport;
import org.eclipse.xtext.common.types.JvmAnyTypeReference;
import org.eclipse.xtext.common.types.JvmConstructor;
import org.eclipse.xtext.common.types.JvmField;
import org.eclipse.xtext.common.types.JvmGenericType;
import org.eclipse.xtext.common.types.JvmIdentifiableElement;
import org.eclipse.xtext.common.types.JvmOperation;
import org.eclipse.xtext.common.types.JvmTypeReference;
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider;
import org.eclipse.xtext.xbase.typing.ITypeProvider;
import org.eclipse.xtext.xbase.validation.UIStrings;

import com.google.inject.Inject;

/**
 * Provides labels for a EObjects.
 * 
 * see http://www.eclipse.org/Xtext/documentation/latest/xtext.html#labelProvider
 */
public class Xtend2LabelProvider extends DefaultEObjectLabelProvider {

	@Inject
	private UIStrings uiStrings;

	@Inject
	private Xtend2Images images;

	@Inject
	private ITypeProvider typeProvider;

	@Inject
	private IXtend2JvmAssociations associations;

	@Inject
	public Xtend2LabelProvider(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}

	public Image image(XtendFile element) {
		return images.forFile();
	}

	public Image image(XtendImport element) {
		return images.forImport();
	}

	public Image image(XtendClass element) {
		JvmGenericType inferredType = associations.getInferredType(element);
		return images.forClass(inferredType.getVisibility());
	}

	public Image image(XtendFunction element) {
		JvmOperation inferredOperation = associations.getDirectlyInferredOperation(element);
		return images.forFunction(inferredOperation.getVisibility(), inferredOperation.isStatic());
	}

	public Image image(JvmOperation element) {
		return images.forDispatcherFunction(element.getVisibility(), element.isStatic());
	}
	
	public Image image(XtendConstructor element) {
		JvmConstructor inferredConstructor = associations.getInferredConstructor(element);
		return images.forConstructor(inferredConstructor.getVisibility());
	}

	public Image image(JvmConstructor element) {
		return images.forConstructor(element.getVisibility());
	}

	public Image image(XtendField element) {
		JvmField inferredField = associations.getJvmField(element);
		return images.forField(inferredField.getVisibility(), inferredField.isStatic(), element.isExtension());
	}

	public Image image(JvmField element) {
		return images.forField(element.getVisibility(), element.isStatic(), false);
	}

	public String text(XtendFile element) {
		return element.eResource().getURI().trimFileExtension().lastSegment();
	}

	public String text(XtendImport element) {
		return element.getImportedNamespace();
	}

	public String text(XtendClass element) {
		return element.getName() + ((element.getTypeParameters().isEmpty()) ? "" : uiStrings.typeParameters(element.getTypeParameters()));
	}

	public String text(XtendConstructor element) {
		return "new" + uiStrings.parameters(associations.getInferredConstructor(element));
	}
	
	public String text(JvmConstructor element) {
		return "new" + uiStrings.parameters(element);
	}
	
	public Object text(XtendFunction element) {
		return signature(element.getName(), associations.getDirectlyInferredOperation(element));
	}
	
	public Object text(JvmOperation element) {
		return signature(element.getSimpleName(), element);
	}
	
	public String text(XtendField element) {
		if (element.getName() == null && element.isExtension())
			return element.getType().getSimpleName();
		return element.getName() +" : " +element.getType().getSimpleName();
	}

	public String text(JvmField element) {
		return element.getSimpleName() +" : " + element.getType().getSimpleName();
	}
	
	protected StyledString signature(String simpleName, JvmIdentifiableElement element) {
		JvmTypeReference returnType = typeProvider.getTypeForIdentifiable(element);
		String returnTypeString = "void";
		if (returnType != null) {
			if (returnType instanceof JvmAnyTypeReference) {
				returnTypeString = "Object";
			} else {
				returnTypeString = returnType.getSimpleName();
			}
		}
		return new StyledString(simpleName + uiStrings.parameters(element)).append(new StyledString(" : " + returnTypeString,StyledString.DECORATIONS_STYLER));
	}

}
