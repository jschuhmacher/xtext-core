/*******************************************************************************
 * Copyright (c) 2015, 2018 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.xtext.wizard

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.util.JUnitVersion

@FinalFieldsConstructor
class TargetPlatformProject extends ProjectDescriptor {

	override getNameQualifier() {
		".target"
	}
	
	override isEclipsePluginProject() {
		false
	}
	
	override isPartOfGradleBuild() {
		false
	}
	
	override isPartOfMavenBuild() {
		true
	}
	
	override isEnabled() {
		config.needsTychoBuild
	}
	
	override setEnabled(boolean enabled) {
		throw new UnsupportedOperationException("The target platform project is activated automatically for Tycho builds")
	}

	override getFiles() {
		val files = newArrayList
		files += super.files
		files += file(Outlet.ROOT, name + ".target", target)
		files
	}
	
	override getSourceFolders() {
		#{}
	}

	def target() '''
		<?xml version="1.0" encoding="UTF-8" standalone="no"?>
		<?pde version="3.8"?>
		<target name="�name�" sequenceNumber="1">
		<locations>
		<location includeAllPlatforms="false" includeConfigurePhase="false" includeMode="planner" includeSource="true" type="InstallableUnit">
		<unit id="org.eclipse.jdt.feature.group" version="0.0.0"/>
		<unit id="org.eclipse.platform.feature.group" version="0.0.0"/>
		<unit id="org.eclipse.pde.feature.group" version="0.0.0"/>
		<unit id="org.eclipse.draw2d.feature.group" version="0.0.0"/>
		<unit id="org.eclipse.emf.sdk.feature.group" version="0.0.0"/>
		�IF isFromExistingEcoreModels�
			<unit id="org.eclipse.xpand" version="0.0.0"/>
			<unit id="org.eclipse.xtend" version="0.0.0"/>
			<unit id="org.eclipse.xtend.typesystem.emf" version="0.0.0"/>
		�ENDIF�
		<repository location="http://download.eclipse.org/releases/2019-03"/>
		</location>
		<location includeAllPlatforms="false" includeConfigurePhase="false" includeMode="planner" includeSource="true" type="InstallableUnit">
		<unit id="org.eclipse.emf.mwe2.launcher.feature.group" version="0.0.0"/>
		<repository location="http://download.eclipse.org/modeling/emft/mwe/updates/milestones"/>
		</location>
		<location includeAllPlatforms="false" includeConfigurePhase="false" includeMode="planner" includeSource="true" type="InstallableUnit">
		<unit id="org.eclipse.xtext.sdk.feature.group" version="0.0.0"/>
		�IF config.xtextVersion.isSnapshot�
			<repository location="http://download.eclipse.org/modeling/tmf/xtext/updates/nightly/"/>
		�ELSEIF config.xtextVersion.isStable�
			<repository location="http://download.eclipse.org/modeling/tmf/xtext/updates/milestones/"/>
		�ELSE�
			<repository location="http://download.eclipse.org/modeling/tmf/xtext/updates/releases/�config.xtextVersion�/"/>
		�ENDIF�
		</location>
		<location includeAllPlatforms="false" includeConfigurePhase="false" includeMode="planner" includeSource="true" type="InstallableUnit">
			<unit id="com.google.gson" version="2.7.0.v20170129-0911"/>
			<unit id="org.antlr.runtime" version="3.2.0.v201101311130"/>
			<unit id="org.junit" version="4.12.0.v201504281640"/>
			�IF config.junitVersion == JUnitVersion.JUNIT_5�
			<unit id="org.junit.jupiter.api" version="5.3.1.v20181005-1442"/>
			<unit id="org.junit.jupiter.engine" version="5.3.1.v20181005-1442"/>
			<unit id="org.junit.platform.commons" version="1.3.1.v20181005-1442"/>
			<unit id="org.junit.platform.engine" version="1.3.1.v20181005-1442"/>
			<unit id="org.junit.platform.launcher" version="1.3.1.v20181005-1442"/>
			<unit id="org.junit.platform.runner" version="1.3.1.v20181005-1442"/>
			<unit id="org.opentest4j" version="1.1.1.v20181005-1442"/>
			�ENDIF�
			<unit id="org.objectweb.asm" version="7.0.0.v20181030-2244"/>
			<unit id="org.objectweb.asm.tree" version="7.0.0.v20181030-2244"/>
			<repository location="http://download.eclipse.org/modeling/tmf/xtext/updates/orbit/2019-03"/>
		</location>
		</locations>
		</target>
	'''

	override buildGradle() {
		throw new UnsupportedOperationException("Eclipse target platforms are not yet supported in Gradle")
	}

	override pom() {
		super.pom => [
			packaging = "eclipse-target-definition"
		]
	}

}
