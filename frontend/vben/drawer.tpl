<template>
  <BasicDrawer
    v-bind="$attrs"
    @register="registerDrawer"
    showFooter
    :title="getTitle"
    width="35%"
    @ok="handleSubmit"
  >
    <BasicForm @register="registerForm" />
  </BasicDrawer>
</template>
<script lang="ts">
  import { defineComponent, ref, computed, unref } from 'vue';
  import { BasicForm, useForm } from '@/components/Form/index';
  import { formSchema } from './{{.modelNameLowerCamel}}.data';
  import { BasicDrawer, useDrawerInner } from '@/components/Drawer';
  import { useI18n } from 'vue-i18n';

  import { create{{.modelName}}, update{{.modelName}} } from '@/api/{{.folderName}}/{{.modelNameLowerCamel}}';

  export default defineComponent({
    name: '{{.modelName}}Drawer',
    components: { BasicDrawer, BasicForm },
    emits: ['success', 'register'],
    setup(_, { emit }) {
      const isUpdate = ref(true);
      const { t } = useI18n();

      const [registerForm, { resetFields, setFieldsValue, validate }] = useForm({
        labelWidth: 160,
        baseColProps: { span: 24 },
        layout: 'vertical',
        schemas: formSchema,
        showActionButtonGroup: false,
      });

      const [registerDrawer, { setDrawerProps, closeDrawer }] = useDrawerInner(async (data) => {
        await resetFields();
        setDrawerProps({ confirmLoading: false });

        isUpdate.value = !!data?.isUpdate;

        if (unref(isUpdate)) {
          await setFieldsValue({
            ...data.record,
          });
        }
      });

      const getTitle = computed(() =>
        !unref(isUpdate) ? t('{{.folderName}}.{{.modelNameLowerCamel}}.add{{.modelName}}') : t('{{.folderName}}.{{.modelNameLowerCamel}}.edit{{.modelName}}'),
      );

      async function handleSubmit() {
        const values = await validate();
        setDrawerProps({ confirmLoading: true });
        {{if .useUUID}}values['id'] = unref(isUpdate) ? values['id'] : '';{{else}}values['id'] = unref(isUpdate) ? Number(values['id']) : 0;{{end}}
        let result = unref(isUpdate) ? await update{{.modelName}}(values) : await create{{.modelName}}(values);
        if (result.code === 0) {
          closeDrawer();
          emit('success');
        }
        setDrawerProps({ confirmLoading: false });
      }

      return {
        registerDrawer,
        registerForm,
        getTitle,
        handleSubmit,
      };
    },
  });
</script>
