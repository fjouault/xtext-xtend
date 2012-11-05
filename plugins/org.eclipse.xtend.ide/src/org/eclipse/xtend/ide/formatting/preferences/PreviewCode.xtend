/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtend.ide.formatting.preferences

class PreviewCode {

	def static String lineWrappingPreviewText() {
		'''
			package test

			import java.io.FileReader
			import java.util.List
			
			class XtendClass {
			
				def testy() {
				}
			
				def readMovies() {
					val movies = new FileReader('data.csv').readLines.map[
						line |line.toFirstUpper.toFirstLower.toFirstLower.toFirstUpper]
					return movies
				}
			
				def List<String> readLines(FileReader fr) {
					return newArrayList("")
				}
			}
		'''.toString
	}

	def static String defaultPreviewText() {
		'''
			class Movies {
			def settings(XtendFormatterConfig config) {
			val List<FormatterSetting> settings = newArrayList()
			for (entry : config.namedProperties.entrySet) {
			val key = entry.key
			val category = key.split(".").head
			var catEnum = Category::byName(category)
			if (catEnum == null)
			catEnum = Category::OTHER
			settings.add(
			createSetting(catEnum, SettingsData$WidgetType::NUMBER_FIELD, key, key.toFirstUpper,
			newArrayList(entry.value.name)))
			}
			return settings
			}
			}
		'''.toString
	}
}
