import React from "react";
import { FieldHelperText, FieldProps, TextField, useModeController } from "@firecms/cloud";

interface CustomColorTextFieldProps {
    color: string
}

export default function CustomColorTextField({
                                                 property,
                                                 value,
                                                 setValue,
                                                 setFieldValue,
                                                 customProps,
                                                 touched,
                                                 includeDescription,
                                                 showError,
                                                 error,
                                                 isSubmitting,
                                                 context, // the rest of the entity values here
                                                 ...props
                                             }: FieldProps<string, CustomColorTextFieldProps>) {

    const { mode } = useModeController();
    const backgroundColor = customProps?.color ?? (mode === "light" ? "#eef4ff" : "#16325f");
    return (
        <>
            <TextField
                inputStyle={{
                    backgroundColor
                }}
                error={!!error}
                disabled={isSubmitting}
                label={error ?? property.name}
                value={value ?? ""}
                onChange={(evt: any) => {
                    setValue(
                        evt.target.value
                    );
                }}/>

            <FieldHelperText includeDescription={includeDescription}
                             showError={showError}
                             error={error}
                             property={property}/>
        </>

    );

}
