/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtend.ide.formatting;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IStorage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.xtend.core.formatting.IFormatterConfigurationProvider;
import org.eclipse.xtend.core.formatting.XtendFormatterConfig;
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess;
import org.eclipse.xtext.ui.resource.IStorage2UriMapper;
import org.eclipse.xtext.util.Pair;

import com.google.inject.Inject;

/**
 * @author Dennis Huebner - Initial contribution and API
 */
public final class FormatterConfigurationProvider implements IFormatterConfigurationProvider {
	@Inject
	private IStorage2UriMapper mapper;
	@Inject
	private IPreferenceStoreAccess preferenceStoreAccess;

	public XtendFormatterConfig getFormatterConfiguration(Resource resource) {
		IProject project = null;
		if (resource.getURI().isPlatform()) {
			Iterable<Pair<IStorage, IProject>> storages = mapper.getStorages(resource.getURI());
			for (Pair<IStorage, IProject> pair : storages) {
				//TODO investigate if there is a possibility, that we can have more than one project
				project = pair.getSecond();
				if (project != null) {
					break;
				}
			}
		}
		IPreferenceStore store = preferenceStoreAccess.getContextPreferenceStore(project);
		Map<String, String> storedValues = new HashMap<String, String>();
		for (String key : new XtendFormatterConfig().asMap().keySet()) {
			String value = store.getString(key);
			if (value != null && value.length() != 0)
				storedValues.put(key, value);
		}
		return new XtendFormatterConfig(storedValues);
	}

}