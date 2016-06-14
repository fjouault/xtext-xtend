/*
* generated by Xtext
*/
package org.eclipse.xtend.ide.outline;

import org.eclipse.xtend.ide.common.outline.IXtendOutlineContext;
import org.eclipse.xtext.ui.editor.outline.IOutlineNode;

import com.google.inject.Inject;
import com.google.inject.Provider;

/**
 * Customization of the default outline structure.
 * 
 * @author Jan Koehnlein
 * @author Dennis Huebner
 */
public class XtendOutlineSourceTreeProvider extends AbstractMultiModeOutlineTreeProvider {

	@Inject
	private Provider<EclipseXtendOutlineSourceContext> xtendOutlineContextProvider;

	@Override
	protected IXtendOutlineContext newContext(IOutlineNode parentNode) {
		EclipseXtendOutlineSourceContext context = xtendOutlineContextProvider.get();
		context.setShowInherited(isShowInherited());
		context.setParentNode(parentNode);
		return context;
	}

}