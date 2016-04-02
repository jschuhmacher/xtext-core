/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.xtext.generator.ui.projectWizard

import com.google.inject.Inject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.xtext.generator.AbstractXtextGeneratorFragment
import org.eclipse.xtext.xtext.generator.XtextGeneratorNaming
import org.eclipse.xtext.xtext.generator.model.FileAccessFactory
import org.eclipse.xtext.xtext.generator.model.GuiceModuleAccess
import org.eclipse.xtext.xtext.generator.model.TypeReference

import static extension org.eclipse.xtext.GrammarUtil.*
import static extension org.eclipse.xtext.xtext.generator.model.TypeReference.typeRef

/**
 * Contributes the registration of compare infrastructure. 
 * 
 * @author Lorenzo Bettini - Initial contribution and API
 */
class SimpleProjectWizardFragment2 extends AbstractXtextGeneratorFragment {

	@Inject
	extension XtextGeneratorNaming

	@Inject
	FileAccessFactory fileAccessFactory

	@Accessors
	private boolean generate = false;

	override generate() {
		if (!generate)
			return;

		if (projectConfig.eclipsePlugin?.manifest !== null) {
			projectConfig.eclipsePlugin.manifest.requiredBundles += #[
				"org.eclipse.ui",
				"org.eclipse.core.runtime",
				"org.eclipse.core.resources",
				"org.eclipse.ui.ide"
			]
		}

		new GuiceModuleAccess.BindingFactory().addTypeToType(
			new TypeReference("org.eclipse.xtext.ui.wizard.IProjectCreator"),
			new TypeReference(projectCreatorClassName)
		).contributeTo(language.eclipsePluginGenModule);

		if (projectConfig.eclipsePlugin?.pluginXml != null) {
			projectConfig.eclipsePlugin.pluginXml.entries += '''
				<extension
					point="org.eclipse.ui.newWizards">
					<wizard
						category="org.eclipse.xtext.projectwiz"
						class="«grammar.eclipsePluginExecutableExtensionFactory»:«projectWizardClassName»"
						id="«projectWizardClassName»"
						name="«grammar.simpleName» Project"
							project="true">
					</wizard>
				</extension>
			'''
		}
		
		generateProjectInfo
		generateNewProjectWizardInitialContents
		generateProjectCreator
		generateNewProjectWizard
	}

	def generateProjectInfo() {
		val projectInfoClass = projectInfoClassName.typeRef

		val file = fileAccessFactory.createJavaFile(projectInfoClass)
		
		file.content = '''
		public class «projectInfoClass.simpleName» extends «"org.eclipse.xtext.ui.wizard.DefaultProjectInfo".typeRef» {

		}
		'''
		file.writeTo(projectConfig.eclipsePlugin.src)
	}

	def generateNewProjectWizardInitialContents() {
		val initialContentsClass = projectWizardInitialContentsClassName.typeRef

		val file = fileAccessFactory.createXtendFile(initialContentsClass)
		
		file.content = '''
		import com.google.inject.Inject
		import org.eclipse.xtext.generator.IFileSystemAccess2
		import org.eclipse.xtext.resource.FileExtensionProvider
		
		class «initialContentsClass.simpleName» {
			@Inject
			FileExtensionProvider fileExtensionProvider
		
			def generateInitialContents(IFileSystemAccess2 fsa) {
				fsa.generateFile(
					"src/model/Model." + fileExtensionProvider.primaryFileExtension,
					''«»'
					/*
					 * This is an example model
					 */
					Hello Xtext!
					''«»'
					)
			}
		}
		'''
		file.writeTo(projectConfig.eclipsePlugin.src)
	}

	def generateProjectCreator() {
		val genClass = getProjectCreatorClassName.typeRef
		val projectInfoClass = projectInfoClassName.typeRef

		val file = fileAccessFactory.createGeneratedJavaFile(genClass)
		
		file.content = '''
		import java.util.HashMap;
		import java.util.List;
		import java.util.Set;

		import org.eclipse.core.resources.IProject;
		import org.eclipse.core.resources.IResource;
		import org.eclipse.core.runtime.CoreException;
		import org.eclipse.core.runtime.IProgressMonitor;
		import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
		import org.eclipse.xtext.generator.IFileSystemAccess;
		import org.eclipse.xtext.generator.IOutputConfigurationProvider;
		import org.eclipse.xtext.generator.OutputConfiguration;
		import org.eclipse.xtext.ui.util.PluginProjectFactory;
		import com.google.common.collect.ImmutableList;
		import com.google.common.collect.Lists;
		import com.google.inject.Inject;
		import com.google.inject.Provider;
		
		public class «genClass.simpleName» extends «"org.eclipse.xtext.ui.wizard.AbstractPluginProjectCreator".typeRef» {
			protected static final String DSL_PROJECT_NAME = "«grammar.namespace»";

			@Inject
			private «getProjectWizardInitialContentsClassName.typeRef.simpleName» initialContents;

			@Inject
			private Provider<EclipseResourceFileSystemAccess2> fileSystemAccessProvider;

			@Inject
			private IOutputConfigurationProvider outputConfigurationProvider;

			@Override
			protected PluginProjectFactory createProjectFactory() {
				PluginProjectFactory projectFactory = super.createProjectFactory();
				projectFactory.setWithPluginXml(false);
				return projectFactory;
			}

			@Override
			protected «projectInfoClass.simpleName» getProjectInfo() {
				return («projectInfoClass.simpleName») super.getProjectInfo();
			}

			@Override
			protected String getModelFolderName() {
				return "src";
			}

			@Override
			protected List<String> getAllFolders() {
				Set<OutputConfiguration> outputConfigurations = outputConfigurationProvider.getOutputConfigurations();
				String outputFolder = "src-gen";
				for (OutputConfiguration outputConfiguration : outputConfigurations) {
					if (IFileSystemAccess.DEFAULT_OUTPUT.equals(outputConfiguration.getName())) {
						outputFolder = outputConfiguration.getOutputDirectory();
						break;
					}
				}
				return ImmutableList.of(getModelFolderName(), outputFolder);
			}
		
			@Override
			protected List<String> getRequiredBundles() {
				return Lists.newArrayList(DSL_PROJECT_NAME);
			}
		
			@Override
			protected void enhanceProject(final IProject project, final IProgressMonitor monitor) throws CoreException {
				EclipseResourceFileSystemAccess2 access = fileSystemAccessProvider.get();
				access.setContext(project);
				access.setMonitor(monitor);
				OutputConfiguration defaultOutput = new OutputConfiguration(IFileSystemAccess.DEFAULT_OUTPUT);
				defaultOutput.setDescription("Output Folder");
				defaultOutput.setOutputDirectory("./");
				defaultOutput.setOverrideExistingResources(true);
				defaultOutput.setCreateOutputDirectory(true);
				defaultOutput.setCleanUpDerivedResources(false);
				defaultOutput.setSetDerivedProperty(false);
				defaultOutput.setKeepLocalHistory(false);
				HashMap<String, OutputConfiguration> outputConfigurations = new HashMap<String, OutputConfiguration>();
				outputConfigurations.put(IFileSystemAccess.DEFAULT_OUTPUT, defaultOutput);
				access.setOutputConfigurations(outputConfigurations);
				initialContents.generateInitialContents(access);
				project.refreshLocal(IResource.DEPTH_INFINITE, monitor);
			}
		}
		'''
		file.writeTo(projectConfig.eclipsePlugin.srcGen)
	}

	def generateNewProjectWizard() {
		val genClass = getProjectWizardClassName.typeRef
		val projectInfoClass = projectInfoClassName.typeRef
			
		val file = fileAccessFactory.createGeneratedJavaFile(genClass)
		file.content =
		'''
		import org.eclipse.ui.dialogs.WizardNewProjectCreationPage;
		import org.eclipse.xtext.ui.wizard.IProjectInfo;
		import org.eclipse.xtext.ui.wizard.IProjectCreator;
		import com.google.inject.Inject;
		
		public class «genClass.simpleName» extends «"org.eclipse.xtext.ui.wizard.XtextNewProjectWizard".typeRef» {
		
			private WizardNewProjectCreationPage mainPage;
		
			@Inject
			public «genClass.simpleName»(IProjectCreator projectCreator) {
				super(projectCreator);
				setWindowTitle("New «grammar.getName()» Project");
			}
		
			/**
			 * Use this method to add pages to the wizard.
			 * The one-time generated version of this class will add a default new project page to the wizard.
			 */
			@Override
			public void addPages() {
				mainPage = new WizardNewProjectCreationPage("basicNewProjectPage");
				mainPage.setTitle("«grammar.getName()» Project");
				mainPage.setDescription("Create a new «grammar.getName()» project.");
				addPage(mainPage);
			}
		
			/**
			 * Use this method to read the project settings from the wizard pages and feed them into the project info class.
			 */
			@Override
			protected IProjectInfo getProjectInfo() {
				«projectInfoClass.simpleName» projectInfo = new «projectInfoClass.simpleName»();
				projectInfo.setProjectName(mainPage.getProjectName());
				return projectInfo;
			}
		
		}
		'''
		file.writeTo(projectConfig.eclipsePlugin.srcGen)
	}

	protected def String getProjectWizardInitialContentsClassName() {
		getProjectWizardClassName + "InitialContents"
	}

	protected def String getProjectWizardClassName() {
		getProjectWizardPackage() + grammar.simpleName + "NewProjectWizard"
	}

	protected def String getProjectCreatorClassName() {
		getProjectWizardPackage() + grammar.simpleName + "ProjectCreator"
	}

	protected def String getProjectInfoClassName() {
		getProjectWizardPackage() + grammar.simpleName + "ProjectInfo"
	}

	protected def String getProjectWizardPackage() {
		grammar.getEclipsePluginBasePackage + ".wizard."
	}
}