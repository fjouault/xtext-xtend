/*******************************************************************************
 * Copyright (c) 2011 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtend.core.tests.serializer;

import org.eclipse.xtend.core.xtend.XtendFile;
import org.eclipse.xtext.junit4.serializer.SerializerTester;

import com.google.inject.Inject;

/**
 * @author Moritz Eysholdt - Initial contribution and API
 */
public class Xtend2SerializerWithNodeModelTest extends AbstractXtend2TestData {

	@Inject
	private SerializerTester tester;

	@Override
	protected void doTest(String fileContents) throws Exception {
		XtendFile file = file(fileContents, true);
		tester.assertSerializeWithNodeModel(file);
	}

}
