/*
* generated by Xtext
*/
package org.eclipse.xtend.ide.outline;

import static com.google.common.collect.Sets.*;

import java.util.Set;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.xtend.core.xtend.XtendFile;
import org.eclipse.xtend.core.xtend.XtendTypeDeclaration;
import org.eclipse.xtend.ide.labeling.XtendJvmLabelProvider;
import org.eclipse.xtext.common.types.JvmDeclaredType;
import org.eclipse.xtext.common.types.JvmGenericType;
import org.eclipse.xtext.common.types.JvmMember;
import org.eclipse.xtext.common.types.JvmTypeReference;
import org.eclipse.xtext.ui.editor.outline.IOutlineNode;
import org.eclipse.xtext.ui.editor.outline.impl.DocumentRootNode;
import org.eclipse.xtext.ui.editor.outline.impl.EObjectNode;

import com.google.inject.Inject;

/**
 * Customization of the default outline structure.
 * 
 * @author Dennis Huebner
 */
public class XtendOutlineJvmTreeProvider extends AbstractMultiModeOutlineTreeProvider {
	@Inject
	XtendJvmLabelProvider xtendJvmLableProvider;

	@Override
	public void internalCreateChildren(DocumentRootNode parentNode, EObject modelElement) {
		String primaryPackage = null;
		if (modelElement instanceof XtendFile) {
			primaryPackage = getOutlineNodeFactory().createPackageAndImporNodes(parentNode, (XtendFile) modelElement);
		}
		EList<EObject> contents = modelElement.eResource().getContents();

		for (EObject eObject : contents) {
			Set<JvmMember> processedFeatures = newHashSet();
			if (eObject instanceof JvmDeclaredType) {
				JvmDeclaredType jvmDeclaredType = (JvmDeclaredType) eObject;
				String packageName = jvmDeclaredType.getPackageName();
				EObjectNode typeNode = createNodeForType(parentNode, jvmDeclaredType, processedFeatures, 0);
				if (!isShowInherited() && packageName != null && (!packageName.equals(primaryPackage))) {
					if (typeNode.getText() instanceof StyledString) {
						typeNode.setText(((StyledString) typeNode.getText()).append(new StyledString(" - "
								+ packageName, StyledString.QUALIFIER_STYLER)));
					}
				}
			}
		}
	}

	@Override
	protected void internalCreateChildren(IOutlineNode parentNode, EObject modelElement) {
		if (modelElement instanceof JvmDeclaredType) {
			Set<JvmMember> processedFeatures = newHashSet();
			createFeatureNodesForType(parentNode, (JvmDeclaredType) modelElement, (JvmDeclaredType) modelElement,
					processedFeatures, 0);
		} else {
			super.internalCreateChildren(parentNode, modelElement);
		}
	}

	@Override
	protected void createInheritedFeatureNodes(IOutlineNode parentNode, JvmDeclaredType baseType,
			Set<JvmMember> processedFeatures, int inheritanceDepth, JvmTypeReference superType) {
		if (superType.getType() instanceof JvmDeclaredType) {
			JvmDeclaredType superClass = ((JvmGenericType) superType.getType());
			createFeatureNodesForType(parentNode, superClass, baseType, processedFeatures, inheritanceDepth + 1);
		}
	}

	@Override
	protected void createNodeForType(IOutlineNode parentNode, EObject someType, Set<JvmMember> processedFeatures,
			int inheritanceDepth) {
		if (someType instanceof JvmDeclaredType) {
			JvmDeclaredType jvmType = (JvmDeclaredType) someType;
			super.createNodeForType(parentNode, jvmType, processedFeatures, inheritanceDepth);
		} else if (someType instanceof XtendTypeDeclaration) {
			EObject jvmElement = getAssociations().getPrimaryJvmElement(someType);
			if (jvmElement instanceof JvmDeclaredType)
				super.createNodeForType(parentNode, (JvmDeclaredType) jvmElement, processedFeatures, inheritanceDepth);
		}
	}

	@Override
	protected ILabelProvider getLabelProvider() {
		return xtendJvmLableProvider;
	}
}
